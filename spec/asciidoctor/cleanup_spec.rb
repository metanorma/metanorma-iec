require "spec_helper"

RSpec.describe Asciidoctor::Iec do
   before(:all) do
  @blank_hdr = blank_hdr_gen
end

  it "moves note from TC/SC officers to metadata" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iec, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      == {blank}

      [NOTE]
      .Note from TC/SC Officers
      ====
      This FDIS is the result of the discussion between the IEC SC21A experts WG 3 during the meeting held in
      Chicago (USA) on April 9th

      This document is also of interest for ISO/ TC114/ WG1 Requirements for Watch batteries
      ====
    INPUT
    <iec-standard xmlns="https://www.metanorma.org/ns/iec" type="semantic" version="#{Metanorma::Iec::VERSION}">
<bibdata type="standard">
  <contributor>
    <role type="author"/>
    <organization>
      <name>International Electrotechnical Commission</name>
      <abbreviation>IEC</abbreviation>
    </organization>
  </contributor>
  <contributor>
    <role type="publisher"/>
    <organization>
      <name>International Electrotechnical Commission</name>
      <abbreviation>IEC</abbreviation>
    </organization>
  </contributor>
  <language>en</language>
  <script>Latn</script>
  <status>
    <stage abbreviation="PPUB">60</stage>
    <substage abbreviation="PPUB">60</substage>
  </status>
  <copyright>
    <from>#{Time.new.year}</from>
    <owner>
      <organization>
        <name>International Electrotechnical Commission</name>
        <abbreviation>IEC</abbreviation>
      </organization>
    </owner>
  </copyright>
  <ext>
    <doctype>article</doctype>
    <horizontal>false</horizontal>
  <editorialgroup>
    <technical-committee/>
    <subcommittee/>
    <workgroup/>
  </editorialgroup>
  <stagename>International standard</stagename>
  <tc-sc-officers-note>
  <p id='_'>
    This FDIS is the result of the discussion between the IEC SC21A
    experts WG 3 during the meeting held in Chicago (USA) on April 9th
  </p>
  <p id='_'>
    This document is also of interest for ISO/ TC114/ WG1 Requirements for
    Watch batteries
  </p>
</tc-sc-officers-note>
  </ext>
</bibdata>
#{boilerplate(Nokogiri::XML(BLANK_HDR + "</iec-standard>"))}
              <sections>
         <clause id="_" inline-header="false" obligation="normative">

       </clause>
       </sections>
       </iec-standard>
    OUTPUT
  end

  it "removes empty text elements" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iec, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      == {blank}
    INPUT
       #{@blank_hdr}
              <sections>
         <clause id="_" inline-header="false" obligation="normative">

       </clause>
       </sections>
       </iec-standard>
    OUTPUT
  end

  it "processes stem-only terms as admitted" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iec, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      == Terms and Definitions

      === stem:[t_90]

      stem:[t_91]

      Time
    INPUT
       #{@blank_hdr}
              <sections>
         <terms id="_" obligation="normative">
         <title>Terms and definitions</title>
         <p id="_">For the purposes of this document, 
       the following terms and definitions apply.</p>
        #{TERMS_BOILERPLATE}
         <term id="term-t90"><preferred><stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><msub><mrow>
  <mi>t</mi>
</mrow>
<mrow>
  <mn>90</mn>
</mrow>
</msub></math></stem></preferred><admitted><stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><msub><mrow>
  <mi>t</mi>
</mrow>
<mrow>
  <mn>91</mn>
</mrow>
</msub></math></stem></admitted>
       <definition><p id="_">Time</p></definition></term>
       </terms>
       </sections>
       </iec-standard>
    OUTPUT
  end

  it "permits multiple blocks in term definition paragraph" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iec, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :stem:
      :no-isobib:

      == Terms and Definitions

      === stem:[t_90]

      [stem]
      ++++
      t_A
      ++++

      This paragraph is extraneous
    INPUT
       #{@blank_hdr}
              <sections>
         <terms id="_" obligation="normative">
         <title>Terms and definitions</title>
         <p id="_">For the purposes of this document, 
       the following terms and definitions apply.</p>
        #{TERMS_BOILERPLATE}
         <term id="term-t90"><preferred><stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><msub><mrow>
  <mi>t</mi>
</mrow>
<mrow>
  <mn>90</mn>
</mrow>
</msub></math></stem></preferred><definition><formula id="_">
         <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><msub><mrow>
  <mi>t</mi>
</mrow>
<mrow>
  <mi>A</mi>
</mrow>
</msub></math></stem>
       </formula><p id="_">This paragraph is extraneous</p></definition>
       </term>
       </terms>
       </sections>
       </iec-standard>
    OUTPUT
  end

  it "keeps any initial boilerplate from terms and definitions" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iec, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      == Terms and Definitions

      I am boilerplate

      * So am I

      === Time

      This paragraph is extraneous
    INPUT
       #{@blank_hdr}
              <sections>
         <terms id="_" obligation="normative"><title>Terms and definitions</title>
         <p id="_">For the purposes of this document, 
       the following terms and definitions apply.</p>
        #{TERMS_BOILERPLATE}
<p id='_'>I am boilerplate</p>
<ul id='_'>
  <li>
    <p id='_'>So am I</p>
  </li>
</ul>
       <term id="term-time">
       <preferred>Time</preferred>
         <definition><p id="_">This paragraph is extraneous</p></definition>
       </term></terms>
       </sections>
       </iec-standard>
    OUTPUT
  end

  it "strips type from xrefs" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iec, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      <<iso216>>

      [bibliography]
      == Clause
      * [[[iso216,ISO 216]]], _Reference_
    INPUT
       #{@blank_hdr}
       <preface>
       <foreword id="_" obligation="informative">
         <title>FOREWORD</title>
         <p id="_">
         <eref type="inline" bibitemid="iso216" citeas="ISO 216"/>
       </p>
       </foreword></preface><sections>
       </sections><bibliography><references id="_" obligation="informative" normative="false">
  <title>Bibliography</title>
  <bibitem id="iso216" type="standard">
  <title format="text/plain">Reference</title>
  <docidentifier>ISO 216</docidentifier>
  <docnumber>216</docnumber>
  <contributor>
    <role type="publisher"/>
    <organization>
      <name>International Organization for Standardization</name>
      <abbreviation>ISO</abbreviation>
    </organization>
  </contributor>
</bibitem>
</references></bibliography>
       </iec-standard>
    OUTPUT
  end

  it "processes localities in term sources" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iec, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      == Terms and Definitions

      === Term1

      [.source]
      <<ISO2191,section=1>>
      INPUT
              #{@blank_hdr}
       <sections>
         <terms id="_" obligation="normative">
         <title>Terms and definitions</title>
         <p id="_">For the purposes of this document, the following terms and definitions apply.</p>
         #{TERMS_BOILERPLATE}
         <term id="term-term1">
         <preferred>Term1</preferred>
         <termsource status="identical">
         <origin bibitemid="ISO2191" type="inline" citeas="">
         <localityStack>
        <locality type="section"><referenceFrom>1</referenceFrom></locality>
         </localityStack>
        </origin>
       </termsource>
       </term>
       </terms>
       </sections>
       </iec-standard>
      OUTPUT
  end

  it "removes extraneous material from Normative References" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iec, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      [bibliography]
      == Normative References

      This is extraneous information

      * [[[iso216,ISO 216]]], _Reference_
    INPUT
      #{@blank_hdr}
      <sections></sections>
      <bibliography><references id="_" obligation="informative" normative="true"><title>Normative references</title>
      <p id="_">The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
             <bibitem id="iso216" type="standard">
         <title format="text/plain">Reference</title>
         <docidentifier>ISO 216</docidentifier>
         <docnumber>216</docnumber>
         <contributor>
           <role type="publisher"/>
           <organization>
             <name>International Organization for Standardization</name>
             <abbreviation>ISO</abbreviation>
           </organization>
         </contributor>
       </bibitem>
      </references>
      </bibliography>
      </iec-standard>
    OUTPUT
  end

  it "inserts IDs into paragraphs" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iec, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      Paragraph
    INPUT
       #{@blank_hdr}
       <sections>
         <p id="_">Paragraph</p>
       </sections>
       </iec-standard>
    OUTPUT
  end

  it "inserts IDs into notes" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iec, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      [example]
      ====
      NOTE: This note has no ID
      ====
    INPUT
       #{@blank_hdr}
       <sections>
         <example id="_">
         <note id="_">
         <p id="_">This note has no ID</p>
       </note>
       </example>
       </sections>
       </iec-standard>
    OUTPUT
  end

  it "moves footnotes inside figures" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iec, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      image::spec/examples/rice_images/rice_image1.png[]

      footnote:[This is a footnote to a figure]

      footnote:[This is another footnote to a figure]
    INPUT
       #{@blank_hdr}
       <sections><figure id="_">
         <image src="spec/examples/rice_images/rice_image1.png" id="_" mimetype="image/png" height="auto" width="auto"/>
       <fn reference="a">
         <p id="_">This is a footnote to a figure</p>
       </fn><fn reference="b">
         <p id="_">This is another footnote to a figure</p>
       </fn></figure>

       </sections>

       </iec-standard>
    OUTPUT
  end

  it "defaults section obligations" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iec, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}

      == Clause
      Text

      [appendix]
      == Clause

      Text
    INPUT
       #{@blank_hdr}
       <sections><clause id="_" inline-header="false" obligation="normative">
         <title>Clause</title>
         <p id="_">Text</p>
       </clause>
       </sections><annex id="_" inline-header="false" obligation="normative">
         <title>Clause</title>
         <p id="_">Text</p>
       </annex>
       </iec-standard>
    OUTPUT
  end

  it "extends clause levels past 5" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iec, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    #{ASCIIDOC_BLANK_HDR}

    == Clause1

    === Clause2

    ==== Clause3

    ===== Clause4

    ====== Clause 5

    [level=6]
    ====== Clause 6

    [level=7]
    ====== Clause 7A

    [level=7]
    ====== Clause 7B

    [level=6]
    ====== Clause 6B

    ====== Clause 5B

    INPUT
    #{@blank_hdr}
    <sections>
  <clause id="_" inline-header="false" obligation="normative">
  <title>Clause1</title>
  <clause id="_" inline-header="false" obligation="normative">
  <title>Clause2</title>
  <clause id="_" inline-header="false" obligation="normative">
  <title>Clause3</title>
  <clause id="_" inline-header="false" obligation="normative"><title>Clause4</title><clause id="_" inline-header="false" obligation="normative">
  <title>Clause 5</title>
<clause id="_" inline-header="false" obligation="normative">
  <title>Clause 6</title>
<clause id="_" inline-header="false" obligation="normative">
  <title>Clause 7A</title>
</clause><clause id="_" inline-header="false" obligation="normative">
  <title>Clause 7B</title>
</clause></clause><clause id="_" inline-header="false" obligation="normative">
  <title>Clause 6B</title>
</clause></clause>




<clause id="_" inline-header="false" obligation="normative">
  <title>Clause 5B</title>
</clause></clause>
</clause>
</clause>
</clause>
</sections>
</iec-standard>
    OUTPUT
  end
end
