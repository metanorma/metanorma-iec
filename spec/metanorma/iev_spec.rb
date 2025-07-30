require "spec_helper"
require "fileutils"

RSpec.describe Metanorma::Iec do
  before(:all) do
    @boilerplate = boilerplate(Nokogiri::XML("#{BLANK_HDR}</metanorma>"))
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
             <metanorma xmlns='https://www.metanorma.org/ns/standoc' type="semantic" version="#{Metanorma::Iec::VERSION}" flavor="iec">
               <bibdata type='standard'>
                          <docidentifier primary="true" type="ISO">IEC 60050:#{Time.now.year}</docidentifier>
           <docidentifier type="iso-reference">IEC 60050:#{Time.now.year}(en)</docidentifier>
           <docidentifier type="URN">urn:iec:std:iec:60050:#{Time.now.year}:en</docidentifier>
           <docidentifier type="iso-undated">IEC 60050</docidentifier>
           <docidentifier type="iso-with-lang">IEC 60050:#{Time.now.year}(en)</docidentifier>
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
                   <flavor>iec</flavor>
                            <subdoctype>vocabulary</subdoctype>
                   <editorialgroup>
                     <agency>IEC</agency>
                   </editorialgroup>
                   <structuredidentifier>
                     <project-number>60050</project-number>
                   </structuredidentifier>
                  <stagename abbreviation="IS">International Standard</stagename>
                 </ext>
               </bibdata>
                        <metanorma-extension>
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
               #{@boilerplate}
               <sections> </sections>
               <bibliography>
                 <references id='_' obligation='informative' normative="true">
                   <title id="_">Normative references</title>
                   <p id='_'>
                    The following documents are referred to in the text in such a way that
                    some or all of their content constitutes requirements of this document.
                    For dated references, only the edition cited applies. For undated
                    references, the latest edition of the referenced document (including any
                    amendments) applies.
                  </p>
                   <bibitem id="_" anchor="A">
                     <formattedref format='application/x-isodoc+xml'>
                       <em>TITLE</em>
                     </formattedref>
                     <docidentifier>B</docidentifier>
                   </bibitem>
                 </references>
               </bibliography>
             </metanorma>
    OUTPUT
    expect(Canon.format_xml(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Canon.format_xml(output)
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
      <metanorma xmlns='https://www.metanorma.org/ns/standoc' type="semantic" version="#{Metanorma::Iec::VERSION}" flavor="iec">
        <bibdata type='standard'>
                  <docidentifier primary="true" type="ISO">IEC 60050:#{Time.now.year}</docidentifier>
           <docidentifier type="iso-reference">IEC 60050:#{Time.now.year}(en)</docidentifier>
           <docidentifier type="URN">urn:iec:std:iec:60050:#{Time.now.year}:en</docidentifier>
           <docidentifier type="iso-undated">IEC 60050</docidentifier>
           <docidentifier type="iso-with-lang">IEC 60050:#{Time.now.year}(en)</docidentifier>
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
            <flavor>iec</flavor>
                            <subdoctype>vocabulary</subdoctype>
            <editorialgroup>
              <agency>IEC</agency>
            </editorialgroup>
            <structuredidentifier>
              <project-number>60050</project-number>
            </structuredidentifier>
            <stagename abbreviation="IS">International Standard</stagename>
          </ext>
        </bibdata>
                 <metanorma-extension>
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
                 #{@boilerplate}
                 <sections>
           <terms id="_" obligation="normative">
             <title id="_">Terms and definitions</title>
             <terms id="_" obligation="normative">
               <title id="_">General</title>
               <term id="_" anchor="term-Term-1">
                 <preferred>
                   <expression>
                     <name>Term 1</name>
                   </expression>
                 </preferred>
               </term>
             </terms>
           </terms>
         </sections>
       </metanorma>
    OUTPUT
    expect(Canon.format_xml(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Canon.format_xml(output)
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
      <metanorma xmlns='https://www.metanorma.org/ns/standoc' type="semantic" version="#{Metanorma::Iec::VERSION}" flavor="iec">
           <bibdata type='standard'>
                      <docidentifier primary="true" type="ISO">IEC 60050:#{Time.now.year}</docidentifier>
           <docidentifier type="iso-reference">IEC 60050:#{Time.now.year}(en)</docidentifier>
           <docidentifier type="URN">urn:iec:std:iec:60050:#{Time.now.year}:en</docidentifier>
           <docidentifier type="iso-undated">IEC 60050</docidentifier>
           <docidentifier type="iso-with-lang">IEC 60050:#{Time.now.year}(en)</docidentifier>
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
               <flavor>iec</flavor>
                        <subdoctype>vocabulary</subdoctype>
               <editorialgroup>
                 <agency>IEC</agency>
               </editorialgroup>
               <structuredidentifier>
                 <project-number>60050</project-number>
               </structuredidentifier>
                <stagename abbreviation="IS">International Standard</stagename>
             </ext>
           </bibdata>
                    <metanorma-extension>
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
           #{@boilerplate}
           <preface>
             <introduction id='_' obligation='informative'>
               <title id="_">INTRODUCTION<br/>Principles and rules followed</title>
                 <p id='_'>Text</p>
               </introduction>
             </preface>
             <sections> </sections>
           </metanorma>
    OUTPUT
    expect(Canon.format_xml(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Canon.format_xml(output)
  end
end
