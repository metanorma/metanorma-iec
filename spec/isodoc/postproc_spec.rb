require "spec_helper"
require "fileutils"

RSpec.describe IsoDoc do
  it "generates file based on string input" do
    FileUtils.rm_f "test.doc"
    FileUtils.rm_f "test.html"
    input = <<~INPUT
              <iso-standard xmlns="http://riboseinc.com/isoxml">
              <bibdata>
              <title>
                  <title type="title-intro" language="en" format="text/plain">Cereals and pulses</title>
          <title type="title-main" language="en" format="text/plain">Specifications and test methods</title>
          <title type="title-part" language="en" format="text/plain">Rice</title>
        </title>
        </bibdata>
          <preface><foreword>
          <note>
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
      </note>
          </foreword></preface>
          </iso-standard>
    INPUT
    IsoDoc::Iec::HtmlConvert
      .new({ wordstylesheet: "spec/assets/word.css",
             htmlstylesheet: "spec/assets/html.css", filename: "test" })
      .convert("test", input, false)
    expect(File.exist?("test.html")).to be true
    html = File.read("test.html", encoding: "UTF-8")
    expect(html).to match(%r{<title>Cereals and pulses&#xA0;&#x2014; Specifications and test methods&#xA0;&#x2014; Rice</title>})
    expect(html).to match(%r{cdnjs\.cloudflare\.com/ajax/libs/mathjax/})
    expect(html).to match(/delimiters: \[\['\(#\(', '\)#\)'\]\]/)
  end

  it "generates HTML output docs with null configuration" do
    FileUtils.rm_f "test.doc"
    FileUtils.rm_f "test.html"
    input = <<~INPUT
              <iso-standard xmlns="http://riboseinc.com/isoxml">
              <bibdata>
              <title>
                  <title type="title-intro" language="en" format="text/plain">Cereals and pulses</title>
          <title type="title-main" language="en" format="text/plain">Specifications and test methods</title>
          <title type="title-part" language="en" format="text/plain">Rice</title>
        </title>
        </bibdata>
          <preface><foreword>
          <note>
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
      </note>
          </foreword></preface>
          </iso-standard>
    INPUT
    IsoDoc::Iec::HtmlConvert
      .new({ wordstylesheet: "spec/assets/word.css",
             htmlstylesheet: "spec/assets/html.css" })
      .convert("test", input, false)
    expect(File.exist?("test.html")).to be true
    html = File.read("test.html", encoding: "UTF-8")
    expect(html).to match(%r{<title>Cereals and pulses&#xA0;&#x2014; Specifications and test methods&#xA0;&#x2014; Rice</title>})
    expect(html).to match(%r{cdnjs\.cloudflare\.com/ajax/libs/mathjax/})
    expect(html).to match(/delimiters: \[\['\(#\(', '\)#\)'\]\]/)
  end

  it "generates Word output docs with null configuration" do
    FileUtils.rm_f "test.doc"
    FileUtils.rm_f "test.html"
    input = <<~INPUT
              <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
          <note>
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
      </note>
          </foreword></preface>
          </iso-standard>
    INPUT
    IsoDoc::Iec::WordConvert
      .new({ wordstylesheet: "spec/assets/word.css",
             htmlstylesheet: "spec/assets/html.css" })
      .convert("test", input, false)
    expect(File.exist?("test.doc")).to be true
    word = File.read("test.doc", encoding: "UTF-8")
    expect(word).to match(/<style>/)
  end

  it "generates HTML output docs with null configuration from file" do
    FileUtils.rm_f "spec/assets/iso.doc"
    FileUtils.rm_f "spec/assets/iso.html"
    IsoDoc::Iec::HtmlConvert
      .new({ wordstylesheet: "word.css", htmlstylesheet: "html.css" })
      .convert("spec/assets/iso.xml", nil, false)
    expect(File.exist?("spec/assets/iso.html")).to be true
    html = File.read("spec/assets/iso.html", encoding: "UTF-8")
    expect(html).to match(/<style>/)
    expect(html).to match(%r{https://use.fontawesome.com})
    expect(html).to match(%r{libs/jquery})
  end

  it "generates Word output docs with null configuration from file" do
    FileUtils.rm_f "spec/assets/iso.doc"
    IsoDoc::Iec::WordConvert
      .new({ wordstylesheet: "word.css", htmlstylesheet: "html.css" })
      .convert("spec/assets/iso.xml", nil, false)
    expect(File.exist?("spec/assets/iso.doc")).to be true
    word = File.read("spec/assets/iso.doc", encoding: "UTF-8")
    expect(word).to match(/<w:WordDocument>/)
    expect(word).to match(/<style>/)
  end

  it "generates Pdf output docs with null configuration from file" do
    FileUtils.rm_f "spec/assets/iso.pdf"
    IsoDoc::Iec::PdfConvert
      .new({ wordstylesheet: "spec/assets/word.css",
             htmlstylesheet: "spec/assets/html.css" })
      .convert("spec/assets/iso.xml", nil, false)
    expect(File.exist?("spec/assets/iso.pdf")).to be true
  end

  it "populates Word template with terms reference labels" do
    FileUtils.rm_f "test.doc"
    FileUtils.rm_f "test.html"
    input = <<~INPUT
              <iso-standard xmlns="http://riboseinc.com/isoxml">
          <sections>
          <terms id="_terms_and_definitions" obligation="normative"><title>1<tab/>Terms and Definitions</title>
      <term id="paddy1">
      <name>1.1</name>
      <preferred>paddy</preferred>
      <definition><p id="_eb29b35e-123e-4d1c-b50b-2714d41e747f">rice retaining its husk after threshing</p></definition>
      <termsource status="modified">[SOURCE:
        <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011"><locality type="clause"><referenceFrom>3.1</referenceFrom></locality>ISO 7301:2011, 3.1</origin>, modified &#x2014; The term "cargo rice" is shown as deprecated, and Note 1 to entry is not included here]
      </termsource></term>
      </terms>
      </sections>
      </iso-standard>
    INPUT
    IsoDoc::Iec::WordConvert
      .new({ wordstylesheet: "spec/assets/word.css",
             htmlstylesheet: "spec/assets/html.css" })
      .convert("test", input, false)
    word = File.read("test.doc", encoding: "UTF-8")
      .sub(/^.*<div class="WordSection3">/m, '<div class="WordSection3">')
      .sub(%r{<br.*$}m, "")
    expect(xmlpp(word)).to be_equivalent_to xmlpp(<<~"OUTPUT")
             <div class="WordSection3">
      #{IEC_TITLE1.gsub(/&#160;/, '&#xA0;')}
                 <div><a name="_terms_and_definitions" id="_terms_and_definitions"></a><h1 class="main">1<span style="mso-tab-count:1">&#xA0; </span>Terms and Definitions</h1>
         <p class="TermNum"><a name="paddy1" id="paddy1"></a>1.1</p><p class="Terms" style="text-align:left;">paddy</p>
         <p class="MsoNormal"><a name="_eb29b35e-123e-4d1c-b50b-2714d41e747f" id="_eb29b35e-123e-4d1c-b50b-2714d41e747f"></a>rice retaining its husk after threshing</p>
         <p class="MsoNormal">[SOURCE: ISO 7301:2011, 3.1, modified &#x2014; The term "cargo rice" is shown as deprecated, and Note 1 to entry is not included here]</p></div>
               </div>
    OUTPUT
  end

  it "processes IsoXML terms for HTML" do
    FileUtils.rm_f "test.html"
    FileUtils.rm_f "test.doc"
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <sections>
          <terms id="_terms_and_definitions" obligation="normative"><title>1<tab/>Terms and Definitions</title>
      <term id="paddy1">
      <name>1.1</name>
      <preferred>paddy</preferred>
      <domain>rice</domain>
      <definition><p id="_eb29b35e-123e-4d1c-b50b-2714d41e747f">rice retaining its husk after threshing</p></definition>
      <termexample id="_bd57bbf1-f948-4bae-b0ce-73c00431f892">
        <p id="_65c9a509-9a89-4b54-a890-274126aeb55c">Foreign seeds, husks, bran, sand, dust.</p>
        <ul>
        <li>A</li>
        </ul>
      </termexample>
      <termexample id="_bd57bbf1-f948-4bae-b0ce-73c00431f894">
        <ul>
        <li>A</li>
        </ul>
      </termexample>
      <termsource status="modified">
        <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011"><locality type="clause"><referenceFrom>3.1</referenceFrom></locality></origin>
          <modification>
          <p id="_e73a417d-ad39-417d-a4c8-20e4e2529489">The term "cargo rice" is shown as deprecated, and Note 1 to entry is not included here</p>
        </modification>
      </termsource></term>
      <term id="paddy">
      <name>1.2</name>
      <preferred>paddy</preferred><admitted>paddy rice</admitted>
      <admitted>rough rice</admitted>
      <deprecates>cargo rice</deprecates>
      <definition><p id="_eb29b35e-123e-4d1c-b50b-2714d41e747f">rice retaining its husk after threshing</p></definition>
      <termexample id="_bd57bbf1-f948-4bae-b0ce-73c00431f893">
        <ul>
        <li>A</li>
        </ul>
      </termexample>
      <termnote id="_671a1994-4783-40d0-bc81-987d06ffb74e">
        <p id="_19830f33-e46c-42cc-94ca-a5ef101132d5">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
      </termnote>
      <termnote id="_671a1994-4783-40d0-bc81-987d06ffb74f">
      <ul><li>A</li></ul>
        <p id="_19830f33-e46c-42cc-94ca-a5ef101132d5">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
      </termnote>
      <termsource status="identical">
        <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011"><locality type="clause"><referenceFrom>3.1</referenceFrom></locality></origin>
      </termsource></term>
      </terms>
      </sections>
      </iso-standard>
    INPUT
    IsoDoc::Iec::HtmlConvert
      .new({ wordstylesheet: "spec/assets/word.css",
             htmlstylesheet: "spec/assets/html.css" })
      .convert("test", input, false)
    expect(File.exist?("test.html")).to be true
    html = File.read("test.html", encoding: "UTF-8")
    expect(html).to match(%r{<h2 class="TermNum" id="paddy1">1\.1</h2>})
    expect(html).to match(%r{<h2 class="TermNum" id="paddy">1\.2</h2>})
  end

  it "inserts default paragraph between two tables for Word" do
    FileUtils.rm_f "test.doc"
    FileUtils.rm_f "test.html"
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <annex id="P" inline-header="false" obligation="normative">
          <example id="_63112cbc-cde0-435f-9553-e0b8c4f5851c">
        <p id="_158d4efa-b1c9-4aec-b325-756de8e4c968">'1M', '01M', and '0001M' all describe the calendar month January.</p>
      </example>
      <example id="_63112cbc-cde0-435f-9553-e0b8c4f5851d">
        <p id="_158d4efa-b1c9-4aec-b325-756de8e4c969">'2M', '02M', and '0002M' all describe the calendar month February.</p>
      </example>
          </annex>
          </iso-standard>
    INPUT
    IsoDoc::Iec::WordConvert
      .new({ wordstylesheet: "spec/assets/word.css",
             htmlstylesheet: "spec/assets/html.css" })
      .convert("test", input, false)
    word = File.read("test.doc", encoding: "UTF-8")
      .sub(/^.*<div class="WordSection3">/m, '<div class="WordSection3">')
      .sub(%r{<br[^>]*>\s*<div class="colophon">.*$}m, "")
    expect(xmlpp(word)).to be_equivalent_to xmlpp(<<~"OUTPUT")
           <div class="WordSection3">
      #{IEC_TITLE1.gsub(/&#160;/, '&#xA0;')}
               <p class="MsoNormal">
                 <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
               </p>
               <div class="Section3"><a name="P" id="P"></a>
                 <div class="example"><a name="_63112cbc-cde0-435f-9553-e0b8c4f5851c" id="_63112cbc-cde0-435f-9553-e0b8c4f5851c"></a>
                   <p class="example"><span style="mso-tab-count:1">&#xA0; </span>'1M', '01M', and '0001M' all describe the calendar month January.</p>
                 </div>
                 <div class="example"><a name="_63112cbc-cde0-435f-9553-e0b8c4f5851d" id="_63112cbc-cde0-435f-9553-e0b8c4f5851d"></a>
                   <p class="example"><span style="mso-tab-count:1">&#xA0; </span>'2M', '02M', and '0002M' all describe the calendar month February.</p>
                 </div>
               </div>
             </div>
    OUTPUT
  end

  it "processes source code in tables (Word)" do
    FileUtils.rm_f "test.doc"
    FileUtils.rm_f "test.html"
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
              <annex id="P" inline-header="false" obligation="normative">
          <sourcecode lang="ruby" id="A">puts "Hello, world."</sourcecode>
          <table id="samplecode">
          <tbody>
          <tr><td>
          <sourcecode lang="ruby" id="B">puts "Hello, world."</sourcecode>
          </td></tr>
          </tbody>
      </table>
          </annex>
          </iso-standard>
    INPUT
    IsoDoc::Iec::WordConvert
      .new({ wordstylesheet: "spec/assets/word.css",
             htmlstylesheet: "spec/assets/html.css" })
      .convert("test", input, false)
    word = File.read("test.doc", encoding: "UTF-8")
      .sub(/^.*<div class="WordSection3">/m, '<div class="WordSection3">')
      .sub(%r{<br[^>]*>\s*<div class="colophon">.*$}m, "")
    expect(xmlpp(word)).to be_equivalent_to xmlpp(<<~"OUTPUT")
         <div class="WordSection3">
      #{IEC_TITLE1.gsub(/&#160;/, '&#xA0;')}
               <p class="MsoNormal">
                 <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
               </p>
               <div class="Section3"><a name="P" id="P"></a>
                 <p class="Sourcecode"><a name="A" id="A"></a>puts "Hello, world."</p>
                            <div align='center' class='table_container'>
               <table class='MsoISOTable' style='mso-table-anchor-horizontal:column;mso-table-overlap:never;border-spacing:0;border-width:1px;'>
                <a name='samplecode' id='samplecode'/>
                     <tbody>
                       <tr>
                         <td style="border-top:solid windowtext 1.5pt;mso-border-top-alt:solid windowtext 1.5pt;border-bottom:solid windowtext 1.5pt;mso-border-bottom-alt:solid windowtext 1.5pt;" class="TABLE-cell">
             <p class="CODE-TableCell"><a name="B" id="B"></a>puts "Hello, world."</p>
             </td>
                       </tr>
                     </tbody>
                   </table>
                 </div>
               </div>
             </div>
    OUTPUT
  end
end
