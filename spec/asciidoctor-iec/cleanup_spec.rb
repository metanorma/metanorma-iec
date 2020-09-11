require "spec_helper"

RSpec.describe Asciidoctor::Iec do
  it "removes empty text elements" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iec, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      == {blank}
    INPUT
       #{BLANK_HDR}
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
       #{BLANK_HDR}
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
       #{BLANK_HDR}
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

  it "strips any initial boilerplate from terms and definitions" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iec, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      == Terms and Definitions

      I am boilerplate

      * So am I

      === Time

      This paragraph is extraneous
    INPUT
       #{BLANK_HDR}
              <sections>
         <terms id="_" obligation="normative"><title>Terms and definitions</title>
         <p id="_">For the purposes of this document, 
       the following terms and definitions apply.</p>
        #{TERMS_BOILERPLATE}

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
       #{BLANK_HDR}
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
              #{BLANK_HDR}
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
      #{BLANK_HDR}
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
       #{BLANK_HDR}
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
       #{BLANK_HDR}
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

  it "moves table key inside table" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iec, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      |===
      |a |b |c
      |===

      Key

      a:: b
    INPUT
       #{BLANK_HDR}
       <sections><table id="_">
         <tbody>
           <tr>
             <td valign="top" align="left">a</td>
             <td valign="top" align="left">b</td>
             <td valign="top" align="left">c</td>
           </tr>
         </tbody>
       <dl id="_">
         <dt>a</dt>
         <dd>
           <p id="_">b</p>
         </dd>
       </dl></table>

       </sections>
       </iec-standard>
    OUTPUT
  end

  it "moves formula key inside formula" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iec, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      [stem]
      ++++
      Formula
      ++++

      where

      a:: b
    INPUT
       #{BLANK_HDR}
       <sections><formula id="_">
          <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><mi>F</mi><mi>or</mi><mi>μ</mi><mi>l</mi><mi>a</mi></math></stem>
       <dl id="_">
         <dt>a</dt>
         <dd>
           <p id="_">b</p>
         </dd>
       </dl></formula>

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
       #{BLANK_HDR}
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

  it "moves figure key inside figure" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", backend: :iec, header_footer: true)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
      #{ASCIIDOC_BLANK_HDR}
      image::spec/examples/rice_images/rice_image1.png[]

      Key

      a:: b
    INPUT
       #{BLANK_HDR}
       <sections><figure id="_">
         <image src="spec/examples/rice_images/rice_image1.png" id="_" mimetype="image/png" height="auto" width="auto"/>
       <dl id="_">
         <dt>a</dt>
         <dd>
           <p id="_">b</p>
         </dd>
       </dl></figure>

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
       #{BLANK_HDR}
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
    #{BLANK_HDR}
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
