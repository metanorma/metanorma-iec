require "spec_helper"
require "fileutils"

RSpec.describe Metanorma::Iec do
  before(:all) do
    @boilerplate = boilerplate(Nokogiri::XML("#{BLANK_HDR}</iec-standard>"))
  end

  it "generates reference boilerplate for IEV" do
    input = <<~INPUT
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :no-isobib:
      :docnumber: 60050

      [bibliography]
      == Normative References

      * [[[A,B]]], _TITLE_
    INPUT
    output = <<~OUTPUT
      <?xml version='1.0' encoding='UTF-8'?>
             <iec-standard xmlns='https://www.metanorma.org/ns/iec' type="semantic" version="#{Metanorma::Iec::VERSION}">
               <bibdata type='standard'>
                 <docidentifier type='ISO'>IEC 60050 ED 1</docidentifier>
                 <docnumber>60050</docnumber>
                 <contributor>
                   <role type='author'/>
                   <organization>
                     <name>International Electrotechnical Commission</name>
                     <abbreviation>IEC</abbreviation>
                   </organization>
                 </contributor>
                 <contributor>
                   <role type='publisher'/>
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
                   <from>#{Time.now.year}</from>
                   <owner>
                     <organization>
                       <name>International Electrotechnical Commission</name>
                       <abbreviation>IEC</abbreviation>
                     </organization>
                   </owner>
                 </copyright>
                 <ext>
                   <doctype>standard</doctype>
                            <subdoctype>vocabulary</subdoctype>
                   <editorialgroup>
                     <agency>IEC</agency>
                   </editorialgroup>
                   <structuredidentifier>
                     <project-number>IEC 60050</project-number>
                   </structuredidentifier>
                         <stagename>International Standard</stagename>
                 </ext>
               </bibdata>
               #{@boilerplate}
               <sections> </sections>
               <bibliography>
                 <references id='_' obligation='informative' normative="true">
                   <title>Normative references</title>
                   <p id='_'>
                    The following documents are referred to in the text in such a way that
                    some or all of their content constitutes requirements of this document.
                    For dated references, only the edition cited applies. For undated
                    references, the latest edition of the referenced document (including any
                    amendments) applies.
                  </p>
                   <bibitem id='A'>
                     <formattedref format='application/x-isodoc+xml'>
                       <em>TITLE</em>
                     </formattedref>
                     <docidentifier>B</docidentifier>
                   </bibitem>
                 </references>
               </bibliography>
             </iec-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end

  it "generates terms boilerplate for IEV" do
    input = <<~INPUT
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :no-isobib:
      :docnumber: 60050

      == Terms and definitions
      === General
      ==== Term 1
    INPUT
    output = <<~OUTPUT
      <iec-standard xmlns='https://www.metanorma.org/ns/iec' type="semantic" version="#{Metanorma::Iec::VERSION}">
        <bibdata type='standard'>
          <docidentifier type='ISO'>IEC 60050 ED 1</docidentifier>
          <docnumber>60050</docnumber>
          <contributor>
            <role type='author'/>
            <organization>
              <name>International Electrotechnical Commission</name>
              <abbreviation>IEC</abbreviation>
            </organization>
          </contributor>
          <contributor>
            <role type='publisher'/>
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
            <from>#{Time.now.year}</from>
            <owner>
              <organization>
                <name>International Electrotechnical Commission</name>
                <abbreviation>IEC</abbreviation>
              </organization>
            </owner>
          </copyright>
          <ext>
            <doctype>standard</doctype>
                            <subdoctype>vocabulary</subdoctype>
            <editorialgroup>
              <agency>IEC</agency>
            </editorialgroup>
            <structuredidentifier>
              <project-number>IEC 60050</project-number>
            </structuredidentifier>
            <stagename>International Standard</stagename>
          </ext>
        </bibdata>
                 #{@boilerplate}
                 <sections>
           <terms id="_" obligation="normative">
             <title>Terms and definitions</title>
             <terms id="_" obligation="normative">
               <title>General</title>
               <term id="term-Term-1">
                 <preferred>
                   <expression>
                     <name>Term 1</name>
                   </expression>
                 </preferred>
               </term>
             </terms>
           </terms>
         </sections>
       </iec-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end

  it "uses IEV introduction title" do
    input = <<~INPUT
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :no-isobib:
      :docnumber: 60050

      == Introduction

      Text
    INPUT
    output = <<~OUTPUT
      <?xml version='1.0' encoding='UTF-8'?>
      <iec-standard xmlns='https://www.metanorma.org/ns/iec' type="semantic" version="#{Metanorma::Iec::VERSION}">
           <bibdata type='standard'>
             <docidentifier type='ISO'>IEC 60050 ED 1</docidentifier>
             <docnumber>60050</docnumber>
             <contributor>
               <role type='author'/>
               <organization>
                 <name>International Electrotechnical Commission</name>
                 <abbreviation>IEC</abbreviation>
               </organization>
             </contributor>
             <contributor>
               <role type='publisher'/>
               <organization>
                 <name>International Electrotechnical Commission</name>
                 <abbreviation>IEC</abbreviation>
               </organization>
             </contributor>
             <language>en</language>
             <script>Latn</script>
             <status>
               <stage abbreviation='PPUB'>60</stage>
               <substage abbreviation='PPUB'>60</substage>
             </status>
             <copyright>
               <from>#{Time.now.year}</from>
               <owner>
                 <organization>
                   <name>International Electrotechnical Commission</name>
                   <abbreviation>IEC</abbreviation>
                 </organization>
               </owner>
             </copyright>
             <ext>
               <doctype>standard</doctype>
                        <subdoctype>vocabulary</subdoctype>
               <editorialgroup>
                 <agency>IEC</agency>
               </editorialgroup>
               <structuredidentifier>
                 <project-number>IEC 60050</project-number>
               </structuredidentifier>
               <stagename>International Standard</stagename>
             </ext>
           </bibdata>
           #{@boilerplate}
           <preface>
             <introduction id='_' obligation='informative'>
               <title>INTRODUCTION<br/>Principles and rules followed</title>
                 <p id='_'>Text</p>
               </introduction>
             </preface>
             <sections> </sections>
           </iec-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end
end
