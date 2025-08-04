require "spec_helper"

RSpec.describe Metanorma::Iec do
  before(:all) do
    @blank_hdr = blank_hdr_gen
  end

  it "moves note from TC/SC officers to metadata" do
    input = <<~INPUT
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
    output = <<~OUTPUT
          <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" version="#{Metanorma::Iec::VERSION}" flavor="iec">
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
                    <contributor>
              <role type="authorizer"><description>Agency</description></role>
              <organization>
                <name>International Electrotechnical Commission</name>
                <abbreviation>IEC</abbreviation>
              </organization>
            </contributor>
        <language>en</language>
        <script>Latn</script>
        <status>
          <stage>60</stage>
          <substage>60</substage>
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
          <doctype>standard</doctype>
          <flavor>iec</flavor>
        <editorialgroup>
          <agency>IEC</agency>
        </editorialgroup>
        <stagename abbreviation="IS">International Standard</stagename>
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
               <metanorma-extension>
      <semantic-metadata>
         <stage-published>true</stage-published>
      </semantic-metadata>
           <presentation-metadata>
             <name>TOC Heading Levels</name>
             <value>2</value>
           </presentation-metadata>
           <presentation-metadata>
             <name>HTML TOC Heading Levels</name>
             <value>2</value>
           </presentation-metadata>
           <presentation-metadata>
             <name>DOC TOC Heading Levels</name>
             <value>3</value>
           </presentation-metadata>
           <presentation-metadata>
             <name>PDF TOC Heading Levels</name>
             <value>3</value>
           </presentation-metadata>
         </metanorma-extension>
      #{boilerplate(Nokogiri::XML(BLANK_HDR + '</metanorma>'))}
                    <sections>
               <clause id="_" inline-header="false" obligation="normative">

             </clause>
             </sections>
             </metanorma>
    OUTPUT
    expect(Canon.format_xml(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "removes empty text elements" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      == {blank}
    INPUT
    output = <<~OUTPUT
      #{@blank_hdr}
             <sections>
        <clause id="_" inline-header="false" obligation="normative">

      </clause>
      </sections>
      </metanorma>
    OUTPUT
    expect(Canon.format_xml(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "keeps any initial boilerplate from terms and definitions" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      == Terms and Definitions

      I am boilerplate

      * So am I

      === Time

      This paragraph is extraneous
    INPUT
    output = <<~OUTPUT
             #{@blank_hdr}
                    <sections>
               <terms id="_" obligation="normative"><title id="_">Terms and definitions</title>
               <p id="_">For the purposes of this document,
             the following terms and definitions apply.</p>
              #{TERMS_BOILERPLATE}
      <p id='_'>I am boilerplate</p>
      <ul id='_'>
        <li>
          <p id='_'>So am I</p>
        </li>
      </ul>
             <term id="_" anchor="term-Time">
             <preferred><expression><name>Time</name></expression></preferred>
               <definition id="_"><verbal-definition id="_"><p id="_">This paragraph is extraneous</p></verbal-definition></definition>
             </term></terms>
             </sections>
             </metanorma>
    OUTPUT
    expect(Canon.format_xml(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "strips type from xrefs" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      <<iso216>>

      [bibliography]
      == Clause
      * [[[iso216,ISO 216]]], _Reference_
    INPUT
    output = <<~OUTPUT
             #{@blank_hdr}
             <preface>
             <foreword id="_" obligation="informative">
               <title id="_">FOREWORD</title>
               <p id="_">
               <eref type="inline" bibitemid="iso216" citeas="ISO&#xa0;216"/>
             </p>
             </foreword></preface><sections>
             </sections><bibliography><references id="_" obligation="informative" normative="false">
        <title id="_">Bibliography</title>
        <bibitem id="_" anchor="iso216" type="standard">
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
             </metanorma>
    OUTPUT
    expect(Canon.format_xml(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "removes extraneous material from Normative References" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      [bibliography]
      == Normative References

      This is extraneous information

      * [[[iso216,ISO 216]]], _Reference_
    INPUT
    output = <<~OUTPUT
      #{@blank_hdr}
      <sections></sections>
      <bibliography><references id="_" obligation="informative" normative="true">
      <title id="_">Normative references</title>
      <p id="_">The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
             <bibitem id="_" anchor="iso216" type="standard">
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
      </metanorma>
    OUTPUT
    expect(Canon.format_xml(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "inserts IDs into paragraphs" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      Paragraph
    INPUT
    output = <<~OUTPUT
      #{@blank_hdr}
      <sections>
        <p id="_">Paragraph</p>
      </sections>
      </metanorma>
    OUTPUT
    expect(Canon.format_xml(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "inserts IDs into notes" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      [example]
      ====
      NOTE: This note has no ID
      ====
    INPUT
    output = <<~OUTPUT
      #{@blank_hdr}
      <sections>
        <example id="_">
        <note id="_">
        <p id="_">This note has no ID</p>
      </note>
      </example>
      </sections>
      </metanorma>
    OUTPUT
    expect(Canon.format_xml(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "moves footnotes inside figures" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      image::spec/examples/rice_images/rice_image1.png[]

      footnote:[This is a footnote to a figure]

      footnote:[This is another footnote to a figure]
    INPUT
    output = <<~OUTPUT
      #{@blank_hdr}
      <sections><figure id="_">
        <image id="_" src="spec/examples/rice_images/rice_image1.png" mimetype="image/png" height="auto" width="auto" filename="spec/examples/rice_images/rice_image1.png"/>
      <fn id="_" reference="a">
        <p id="_">This is a footnote to a figure</p>
      </fn><fn id="_" reference="b">
        <p id="_">This is another footnote to a figure</p>
      </fn></figure>

      </sections>

      </metanorma>
    OUTPUT
    expect(Canon.format_xml(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "defaults section obligations" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}

      == Clause
      Text

      [appendix]
      == Clause

      Text
    INPUT
    output = <<~OUTPUT
      #{@blank_hdr}
      <sections><clause id="_" inline-header="false" obligation="normative">
        <title id="_">Clause</title>
        <p id="_">Text</p>
      </clause>
      </sections><annex id="_" inline-header="false" obligation="normative">
        <title id="_">Clause</title>
        <p id="_">Text</p>
      </annex>
      </metanorma>
    OUTPUT
    expect(Canon.format_xml(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "extends clause levels past 5" do
    input = <<~INPUT
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
    output = <<~OUTPUT
          #{@blank_hdr}
            <sections>
             <clause id="_" inline-header="false" obligation="normative">
                <title id="_">Clause1</title>
                <clause id="_" inline-header="false" obligation="normative">
                   <title id="_">Clause2</title>
                   <clause id="_" inline-header="false" obligation="normative">
                      <title id="_">Clause3</title>
                      <clause id="_" inline-header="false" obligation="normative">
                         <title id="_">Clause4</title>
                         <clause id="_" inline-header="false" obligation="normative">
                            <title id="_">Clause 5</title>
                            <clause id="_" inline-header="false" obligation="normative">
                               <title id="_">Clause 6</title>
                               <clause id="_" inline-header="false" obligation="normative">
                                  <title id="_">Clause 7A</title>
                               </clause>
                               <clause id="_" inline-header="false" obligation="normative">
                                  <title id="_">Clause 7B</title>
                               </clause>
                            </clause>
                            <clause id="_" inline-header="false" obligation="normative">
                               <title id="_">Clause 6B</title>
                            </clause>
                         </clause>
                         <clause id="_" inline-header="false" obligation="normative">
                            <title id="_">Clause 5B</title>
                         </clause>
                      </clause>
                   </clause>
                </clause>
             </clause>
          </sections>
       </metanorma>
    OUTPUT
    expect(Canon.format_xml(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Canon.format_xml(output)
  end
end
