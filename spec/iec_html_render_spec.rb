# frozen_string_literal: true

require "spec_helper"
require "metanorma/iec/document"
require "metanorma/iec/html"
require "metanorma/html/generator"

# The renderer registration contract: the IEC root must dispatch —
# an unregistered root renders reader chrome with no document body.
RSpec.describe "Metanorma::Iec::Html::Renderer" do
  let(:fixture) do
    Dir[File.expand_path("fixtures/**/*presentation*.xml", __dir__)].first
  end

  it "renders the IEC root to a document body, not an empty shell" do
    skip "no presentation fixture" unless fixture

    model = Metanorma::Iec::Document::Root.from_xml(
      File.read(fixture, encoding: "utf-8"),
    )
    html = Metanorma::Html::Generator.generate(model)
    page = Nokogiri::HTML(html)
    page.css("header, nav, .header-actions, button, kbd").remove

    expect(page.css("p").size).to be > 5,
                                  "document body rendered no content (root dispatch missing)"
    expect(page.at("body").text).to include("IEC")
  end

  it "is the renderer the flavor registry resolves" do
    entry = Metanorma::Core::Flavors.find(:iec)
    expect(entry.renderers[:html].call(nil)).to eq(Metanorma::Iec::Html::Renderer)
  end
end
