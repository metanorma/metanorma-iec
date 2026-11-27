# frozen_string_literal: true

require "metanorma/iec"

RSpec.describe Metanorma::Iec::Sts do
  let(:presentation_xml) do
    <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/iso" type="presentation">
        <bibdata type="standard">
          <title language="en" type="main">Test IEC document</title>
          <docidentifier type="IEC">IEC 99999:2026</docidentifier>
          <edition>1</edition>
          <language>en</language>
          <script>Latn</script>
          <status><stage>40</stage><substage>60</substage></status>
          <copyright><owner><organization><abbreviation>IEC</abbreviation></organization></owner></copyright>
        </bibdata>
        <sections>
          <clause id="c1" obligation="normative" displayorder="1"><title>Scope</title></clause>
        </sections>
      </metanorma>
    XML
  end

  it "resolves the IEC profile through the shared engine registry" do
    profile = described_class::Profile.instance
    expect(profile.name).to eq(:iec)
    expect(Metanorma::Document::Sts::Profiles.resolve(:iec)).to eq(profile)
    expect(profile.reader_class).to eq(Metanorma::Iec::Document::Root)
  end

  it "converts an IEC document to NISO STS through the shared engine" do
    model = described_class.convert_to_model(presentation_xml)
    expect(model).to respond_to(:to_xml)
    xml = described_class.convert(presentation_xml)
    expect(xml).to include("<standard")
    expect(xml).to include("Test IEC document")
  end

  it "loads the canonical IEC label style profile through the ladl engine" do
    profile = described_class.label_profile
    expect(profile).to be_a(Ladl::Profile)
  end
end
