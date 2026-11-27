# frozen_string_literal: true

require "rspec"
require "nokogiri"
require "metanorma/iec/document"
require "metanorma/iec/html"
require "metanorma/html/generator"
require "tmpdir"

RSpec.describe "IEC-owned HTML theme" do
  def presentation_document(script: "Latn")
    fixture = File.expand_path("fixtures/iec/iec-rice-fr.presentation.xml", __dir__)
    bibdata = Nokogiri::XML(File.read(fixture)).at("//xmlns:bibdata")
    bibdata.at("./xmlns:script").content = script
    Metanorma::Iec::Document::Root.from_xml(<<~XML)
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="presentation" flavor="iec">
        #{bibdata.to_xml}
        <sections>
          <clause id="scope" displayorder="1">
            <fmt-title>1 Scope</fmt-title>
            <p id="scope-text">IEC body content stays available.</p>
          </clause>
        </sections>
      </metanorma>
    XML
  end

  let(:document) { presentation_document }
  let(:renderer) do
    instance = Metanorma::Iec::Html::Renderer.new
    instance.document = document
    instance
  end

  let(:themes_dir) { File.expand_path("../lib/metanorma/iec/themes", __dir__) }

  it "registers the IEC theme from this gem" do
    theme = Metanorma::Html::Theme.load(:iec)

    expect(theme).to have_attributes(
      theme_dir: File.join(themes_dir, "iec"), publisher_name: "IEC",
      publishers: ["IEC"], logos_light: { "IEC" => "iec-logo.svg" },
    )
  end

  it "uses the IEC web palette" do
    expect(Metanorma::Html::Theme.load(:iec)).to have_attributes(
      primary: "#0060aa", accent_deep: "#003863", text_color: "#12375f",
      warm: "#f36f36", dark_bg: "#10161d",
    )
  end

  it "styles the body elements of an IEC document" do
    css = File.read(File.join(themes_dir, "iec", "custom.css"))
    selectors = [
      ".main-section :is(h1, h2, h3, h4, h5, h6) > .caption-label",
      ".main-section .annex-title", ".main-section .TermNum",
      ".main-section p.term-source", ".main-section .note-block",
      ".main-section .example", ".main-section .mn-labeled-list .li-label",
      ".main-section .table-caption", ".main-section table.table-block",
      ".main-section .TableFootnoteRef", ".main-section figcaption",
      ".main-section .footnotes .footnote", ".main-section .biblio-entry",
      '[data-theme="dark"], [data-theme="oled"]',
      ".iec-title-section .cover-title-fr"
    ]

    expect(selectors.reject { |selector| css.include?(selector) }).to be_empty
  end

  it "uses the IEC converter's body, heading and code fonts" do
    expect(renderer.theme.font_body).to eq('"Arial", sans-serif')
    expect(renderer.theme.font_sans).to eq('"Arial", sans-serif')
    expect(renderer.theme.font_mono).to eq('"Courier New", monospace')
    expect(renderer.theme.font_url).to be_nil
  end

  it "keeps the IEC simplified-Chinese font choice" do
    renderer.document = presentation_document(script: "Hans")

    expect(renderer.theme.font_body).to eq('"Source Han Sans", serif')
    expect(renderer.theme.font_sans).to eq('"Source Han Sans", sans-serif')
    expect(Metanorma::Html::Theme.load(:iec).font_body).to eq('"Arial", sans-serif')
  end

  it "renders one title per language with draft identity and document body" do
    html = renderer.generate_full_document(document)
    page = Nokogiri::HTML(html)
    cover = page.at(".iec-title-section")

    expect(cover).not_to be_nil
    expect(cover.css('.cover-title[lang="en"]').length).to eq(1)
    expect(cover.css('.cover-title-fr[lang="fr"]').length).to eq(1)
    expect(cover.at('.cover-title[lang="en"]').text).to include("Cereals and pulses")
    expect(cover.at('.cover-title-fr[lang="fr"]').text).to include("Céréales et légumineuses")
    expect(cover.text).to include("TC 34")
    expect(cover.text).to match(/CD.*stage/)
    expect(cover.at(".cover-secretariat")).to be_nil
    expect(page.at("#scope-text").text).to eq("IEC body content stays available.")
    expect(page.css("style").text).to include(
      "--mn-primary: #0060aa;", "--iec-link: var(--mn-primary);",
      ".iec-cover-identity", '--font-body: "Arial", sans-serif'
    )
  end

  it "does not replace an explicit theme object" do
    theme = Metanorma::Html::Theme.load(:iec)
    theme.font_body = '"Organization Font", serif'
    original_dir = theme.theme_dir

    renderer.generate_full_document(document, theme: theme)

    expect(renderer.theme).to equal(theme)
    expect(theme.font_body).to eq('"Organization Font", serif')
    expect(theme.theme_dir).to eq(original_dir)
  end

  it "keeps organization theme templates ahead of the IEC defaults" do
    Dir.mktmpdir("iec-organization-theme") do |dir|
      Dir.mkdir(File.join(dir, "templates"))
      File.write(File.join(dir, "theme.yaml"), "publisher_name: Organization\n")
      File.write(File.join(dir, "templates", "_standard_cover.html.liquid"),
                 '<section id="organization-cover">Organization cover</section>')

      html = renderer.generate_full_document(document, theme: dir)
      page = Nokogiri::HTML(html)

      expect(page.at("#organization-cover").text).to eq("Organization cover")
      expect(page.at(".iec-title-section")).to be_nil
      expect(page.at("#scope-text").text).to eq("IEC body content stays available.")
    end
  end
end
