require "spec_helper"
require "fileutils"

RSpec.describe Asciidoctor::Iec do
  before(:all) do
    @boilerplate = boilerplate(Nokogiri::XML(BLANK_HDR + "</iec-standard>"))
  end

  it "generates terms boilerplate for IEV" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", *OPTIONS)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
            <doctype>article</doctype>
                            <horizontal>false</horizontal>
                            <subdoctype>vocabulary</subdoctype>
            <editorialgroup>
              <technical-committee/>
              <subcommittee/>
              <workgroup/>
            </editorialgroup>
            <structuredidentifier>
              <project-number>IEC 60050</project-number>
            </structuredidentifier>
            <stagename>International standard</stagename>
          </ext>
        </bibdata>
                 #{@boilerplate}
        <sections>
          <clause id='_' obligation='normative'>
            <title>Terms and definitions</title>
            <terms id='_' obligation='normative'>
              <title>General</title>
              <term id='term-term-1'>
                <preferred><expression><name>Term 1</name></expression></preferred>
              </term>
            </terms>
          </clause>
        </sections>
      </iec-standard>

    OUTPUT
  end

  it "uses IEV introduction title" do
    expect(xmlpp(strip_guid(Asciidoctor.convert(<<~"INPUT", *OPTIONS)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
               <doctype>article</doctype>
                        <subdoctype>vocabulary</subdoctype>
                        <horizontal>false</horizontal>
               <editorialgroup>
                 <technical-committee/>
                 <subcommittee/>
                 <workgroup/>
               </editorialgroup>
               <structuredidentifier>
                 <project-number>IEC 60050</project-number>
               </structuredidentifier>
               <stagename>International standard</stagename>
             </ext>
           </bibdata>
           #{@boilerplate}
           <preface>
             <introduction id='_' obligation='informative'>
               <title>INTRODUCTION&lt;br/&gt;Principles and rules followed</title>
               <p id='_'>Text</p>
             </introduction>
           </preface>
           <sections> </sections>
         </iec-standard>
    OUTPUT
  end
end
