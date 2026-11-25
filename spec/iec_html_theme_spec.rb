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

  it "retains IEC publisher identity and colors without changing the shared theme" do
    shared = Metanorma::Html::Theme.load(:iec)
    theme = renderer.theme

    expect(theme.publisher_name).to eq("IEC")
    expect(theme.publishers).to eq(shared.publishers)
    expect(theme.primary).to eq(shared.primary)
    expect(theme.logos_light).to eq(shared.logos_light)
    expect(Metanorma::Html::Theme.load(:iec).font_body).to eq(shared.font_body)
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
    expect(page.css("style").text).to include('.iec-cover-identity', '--font-body: "Arial", sans-serif')
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
