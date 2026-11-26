# frozen_string_literal: true

require "rspec"
require "nokogiri"
require "metanorma/iec/document"
require "metanorma/iec/html"
require "metanorma/html/generator"

# isodoc prints the dated primary identifier with the language mark
# ("IEC CD 17301-1:2016 ED2(E)") and the first token of the stage name
# ("CD stage"). The HTML cover printed the undated identifier and the
# full pubid stage abbreviation ("CD IS stage").
RSpec.describe "IEC HTML cover identity" do
  let(:fixture) do
    File.expand_path("fixtures/iec/iec-rice-fr.presentation.xml", __dir__)
  end
  let(:cover) do
    model = Metanorma::Iec::Document::Root.from_xml(File.read(fixture))
    Nokogiri::HTML(Metanorma::Html::Generator.generate(model))
      .at(".iec-title-section")
  end

  it "keeps the year and language mark on the document identifier" do
    ids = cover.css(".cover-doc-id").map { |n| n.text.strip }
    expect(ids).to include(a_string_starting_with("IEC CD 17301-1:2016 ED2(E)"))
  end

  it "names the stage by its IEC code, without the document type" do
    expect(cover.at(".cover-stage").text.strip).to eq("CD stage")
  end
end
