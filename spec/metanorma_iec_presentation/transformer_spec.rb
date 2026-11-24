# frozen_string_literal: true

require "spec_helper"
require "metanorma/iec/presentation/transformer"
require "metanorma/iec/html"

RSpec.describe Metanorma::Iec::Presentation::Transformer do
  let(:inline) { Metanorma::Document::Components::Inline }
  let(:sections) { Metanorma::IsoDocument::Sections }
  let(:para) { Metanorma::Document::Components::Paragraphs::ParagraphBlock }

  def ordered(node, *names)
    node.element_order = names.map do |n|
      if n.is_a?(Array)
        Lutaml::Xml::Element.new("Text", "text",
                                 text_content: n.first)
      else
        Lutaml::Xml::Element.new(
          "Element", n
        )
      end
    end
    node
  end

  def clause(id, title, body)
    c = sections::IsoClauseSection.new(
      id: id, title: inline::TitleWithAnnotationElement.new(text: [title]),
      paragraphs: [para.new(text: [body])]
    )
    ordered(c, "title", "p")
  end

  def fixture
    container = ordered(
      sections::IsoSections.new(clause: [clause("scope", "Scope", "Body one."),
                                         clause("method", "Method",
                                                "Body two.")]),
      "clause", "clause"
    )
    meta = Metanorma::IsoDocument::Metadata
    bib = meta::IsoBibliographicItem.new(
      type: "standard",
      titles: [meta::TitleFull.new(value: "Native IEC", language: "en",
                                   _type: "main")],
      doc_identifier: [meta::DocIdentifier.new(value: "IEC 99999:2026",
                                               type: "IEC", primary: true)],
      language: [meta::LanguageElement.new(value: "en")],
    )
    Metanorma::Iec::Document::Root.new(type: "semantic", flavor: "iec",
                                       bibdata: bib, sections: container)
  end

  it "transforms an IEC root natively with the shared LADL profile" do
    semantic = fixture
    before = Marshal.dump(semantic)
    result = described_class.new.call(semantic, flavor: :iec, options: {})
    expect(result).to be_instance_of(Metanorma::Iec::Document::Root)
    expect(result.type).to eq("presentation")
    expect(Marshal.dump(semantic)).to eq(before)
    expect(result.sections.clause.map(&:displayorder)).to eq([1, 2])
    title = result.sections.clause.first.fmt_title
    expect(title.span.first.text).to eq(["Clause 1 "])
  end

  it "renders through the registered IEC HTML renderer" do
    result = described_class.new.call(fixture, flavor: :iec, options: {})
    renderer = Metanorma::Core::Flavors.renderer_for(result, format: :html,
                                                             flavor: :iec)
    expect(renderer).to eq(Metanorma::Iec::Html::Renderer)
    expect(renderer.new.generate_body(result)).to include("Scope", "Body two.")
  end

  it "uses an injected labeler and requires it to return the same root" do
    other = ->(_root, **) { fixture }
    expect do
      described_class.new.call(fixture, flavor: :iec,
                                        options: { document_labeler: other })
    end.to raise_error(ArgumentError, /must return its supplied IEC Root/)
  end

  it "rejects non-IEC roots and flavors" do
    iso_root = Metanorma::Iso::Document::Root.new(type: "semantic")
    expect { described_class.new.call(iso_root, flavor: :iec, options: {}) }
      .to raise_error(ArgumentError, /IEC Root/)
    expect { described_class.new.call(fixture, flavor: :iso, options: {}) }
      .to raise_error(ArgumentError, /IEC Root/)
  end

  it "fails explicitly on unsupported math" do
    root = fixture
    para = root.sections.clause.first.paragraphs.first
    para.stem = [inline::StemInlineElement.new]
    expect { described_class.new.call(root, flavor: :iec, options: {}) }
      .to raise_error(
        Metanorma::Iso::Presentation::Transformer::UnsupportedContent, /stem/
      )
  end
end
