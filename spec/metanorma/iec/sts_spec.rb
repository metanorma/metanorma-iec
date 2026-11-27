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
          <contributor><role type="publisher"/><organization><name>International Electrotechnical Commission</name><abbreviation>IEC</abbreviation></organization></contributor>
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

  it "keys term sections on the presentation term number" do
    xml = presentation_xml.sub(
      %(<clause id="c1" obligation="normative" displayorder="1"><title>Scope</title></clause>),
      <<~XML.chomp,
        <clause id="c1" type="terms" obligation="normative" displayorder="1"><title>Terms</title>
          <term id="paddy" anchor="paddy"><fmt-name><span class="fmt-caption-label"><span class="fmt-autonum">3</span><span class="fmt-autonum-delim">.</span><span class="fmt-autonum">1</span></span></fmt-name><fmt-xref-label>3.1</fmt-xref-label><preferred><expression><name>paddy</name></expression></preferred></term>
        </clause>
      XML
    )
    expect(described_class.convert(xml)).to include(%(<term-sec id="sec_3.1">))
  end

  it "types term-entry cross-references" do
    xml = presentation_xml.sub(
      %(<clause id="c1" obligation="normative" displayorder="1"><title>Scope</title></clause>),
      <<~XML.chomp,
        <clause id="c1" type="terms" obligation="normative" displayorder="1"><title>Terms</title>
          <term id="paddy" anchor="paddy"><fmt-name><span class="fmt-caption-label"><span class="fmt-autonum">3</span><span class="fmt-autonum-delim">.</span><span class="fmt-autonum">1</span></span></fmt-name><fmt-xref-label>3.1</fmt-xref-label><preferred><expression><name>paddy</name></expression></preferred></term>
          <term id="husked" anchor="husked"><fmt-name><span class="fmt-caption-label"><span class="fmt-autonum">3</span><span class="fmt-autonum-delim">.</span><span class="fmt-autonum">2</span></span></fmt-name><fmt-xref-label>3.2</fmt-xref-label><preferred><expression><name>husked</name></expression></preferred><definition><verbal-definition><p>from <xref target="paddy" style="short"/></p></verbal-definition></definition></term>
        </clause>
      XML
    )
    expect(described_class.convert(xml)).to include(
      %(<xref ref-type="custom" custom-type="term-entry" rid="term_3.1">),
    )
  end

  it "keeps no-break spaces in standard references" do
    xml = presentation_xml.sub(
      %(<clause id="c1" obligation="normative" displayorder="1"><title>Scope</title></clause>),
      %(<clause id="c1" obligation="normative" displayorder="1"><title>Scope</title><p id="p1">Part 2 applies to Table 3.</p></clause>),
    )
    expect(described_class.convert(xml)).to include("Part 2 applies to Table 3.")
  end

  it "builds the IEC std-ident and std-org from the publisher" do
    xml = described_class.convert(presentation_xml)
    expect(xml).to include("<originator>IEC</originator>")
    expect(xml).to include("<std-org-abbrev>IEC</std-org-abbrev>")
  end

  it "declares the IEC/ISO coding profile in processing-meta" do
    expect(described_class.convert(presentation_xml)).to include(
      %(<processing-meta tagset-family="sts" base-tagset="interchange"),
    )
  end

  it "validates IEC output against the IEC/ISO coding guideline rules" do
    xml = described_class.convert(presentation_xml)
    expect(described_class.validate(xml).errors.map(&:rule_id))
      .to eq(Metanorma::Iso::Sts.validate(xml).errors.map(&:rule_id))
  end

  it "loads the canonical IEC label style profile through the ladl engine" do
    profile = described_class.label_profile
    expect(profile).to be_a(Ladl::Profile)
  end
end
