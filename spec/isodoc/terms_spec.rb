require "spec_helper"

RSpec.describe IsoDoc do
  it "processes IsoXML terms" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <sections>
          <terms id="_terms_and_definitions" obligation="normative"><title>Terms and definitions</title>

      <term id="paddy1"><preferred>paddy</preferred>
      <domain>rice</domain>
      <definition><verbal-definition><p id="_eb29b35e-123e-4d1c-b50b-2714d41e747f">rice retaining its husk after threshing</p></verbal-definition></definition>
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
        <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011"><locality type="clause"><referenceFrom>3.1</referenceFrom></locality>ISO 7301:2011, 3.1</origin>
          <modification>
          <p id="_e73a417d-ad39-417d-a4c8-20e4e2529489">The term "cargo rice" is shown as deprecated, and Note 1 to entry is not included here</p>
        </modification>
      </termsource></term>

      <term id="paddy">
      <preferred>paddy</preferred><admitted>paddy rice</admitted>
      <admitted>rough rice</admitted>
      <deprecates>cargo rice</deprecates>
      <definition><verbal-definition><p id="_eb29b35e-123e-4d1c-b50b-2714d41e747f">rice retaining its husk after threshing</p></verbal-definition></definition>
      <termnote id="_671a1994-4783-40d0-bc81-987d06ffb74e">
        <p id="_19830f33-e46c-42cc-94ca-a5ef101132d5">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
      </termnote>
      <termnote id="_671a1994-4783-40d0-bc81-987d06ffb74f">
      <ul><li>A</li></ul>
        <p id="_19830f33-e46c-42cc-94ca-a5ef101132d5">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
      </termnote>
      <termexample id="_bd57bbf1-f948-4bae-b0ce-73c00431f893">
        <ul>
        <li>A</li>
        </ul>
      </termexample>
      <termsource status="identical">
        <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011"><locality type="clause"><referenceFrom>3.1</referenceFrom></locality>ISO 7301:2011, 3.1</origin>
      </termsource></term>
      </terms>
      </sections>
      </iso-standard>
    INPUT
    presxml = <<~INPUT
          <?xml version='1.0'?>
          <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          #{PREFACE}</preface>
          <sections>
          <terms id="_" obligation="normative" displayorder="8"><title depth="1">1<tab/>Terms and definitions</title>

      <term id="paddy1">
      <name>1.1</name><preferred>paddy</preferred>
      <definition><p id="_">&#x3c;rice&#x3e; rice retaining its husk after threshing</p></definition>
      <termexample id="_">
      <name>EXAMPLE 1</name>
        <p id="_">Foreign seeds, husks, bran, sand, dust.</p>
        <ul>
        <li>A</li>
        </ul>
      </termexample>
      <termexample id="_">
      <name>EXAMPLE 2</name>
        <ul>
        <li>A</li>
        </ul>
      </termexample>

      <termsource status="modified">[SOURCE:
        <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011"><locality type="clause"><referenceFrom>3.1</referenceFrom></locality>ISO 7301:2011, 3.1</origin>, modified &#x2014; The term "cargo rice" is shown as deprecated, and Note 1 to entry is not included here]
      </termsource></term>

      <term id="paddy">
      <name>1.2</name>
      <preferred>paddy</preferred><admitted>paddy rice</admitted>
      <admitted>rough rice</admitted>
      <deprecates>DEPRECATED: cargo rice</deprecates>
      <definition><p id="_">rice retaining its husk after threshing</p></definition>
      <termnote id="_">
      <name>Note 1 to entry</name>
        <p id="_">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
      </termnote>
      <termnote id="_">
      <name>Note 2 to entry</name>
      <ul><li>A</li></ul>
        <p id="_">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
      </termnote>
      <termexample id="_">
      <name>EXAMPLE</name>
        <ul>
        <li>A</li>
        </ul>
      </termexample>
      <termsource status="identical">[SOURCE:
        <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011"><locality type="clause"><referenceFrom>3.1</referenceFrom></locality>ISO 7301:2011, 3.1</origin>]
      </termsource></term>
      </terms>
      </sections>
      </iso-standard>
    INPUT
    html = <<~OUTPUT
      #{HTML_HDR}
          #{IEC_TITLE1}
               <div id="_"><h1>1&#160; Terms and definitions</h1>
         <p class="TermNum" id="paddy1">1.1</p><p class="Terms" style="text-align:left;">paddy</p>

         <p id="_">&lt;rice&gt; rice retaining its husk after threshing</p>
         <div id="_" class="example"><p><span class="example_label">EXAMPLE 1</span>&#160; Foreign seeds, husks, bran, sand, dust.</p>
         <div class="ul_wrap">
          <ul>
           <li>A</li>
           </ul></div></div>
         <div id="_" class="example"><p><span class="example_label">EXAMPLE 2</span>&#160; </p>
         <div class="ul_wrap">
           <ul>
           <li>A</li>
           </ul>
         </div>
         </div>

         <p>[SOURCE:
           ISO 7301:2011, 3.1, modified &#x2014; The term "cargo rice" is shown as deprecated, and Note 1 to entry is not included here]
         </p><p class="TermNum" id="paddy">1.2</p><p class="Terms" style="text-align:left;">paddy</p><p class="AltTerms" style="text-align:left;">paddy rice</p>
         <p class="AltTerms" style="text-align:left;">rough rice</p>
         <p class="DeprecatedTerms" style="text-align:left;">DEPRECATED: cargo rice</p>
         <p id="_">rice retaining its husk after threshing</p>
         <div id="_" class="example"><p><span class="example_label">EXAMPLE</span>&#160; </p>
         <div class="ul_wrap">
           <ul>
           <li>A</li>
           </ul>
         </div>
         </div>
         <div id="_" class="Note"><p>Note 1 to entry: The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p></div>
         <div id='_' class="Note"><p>Note 2 to entry:
         <div class="ul_wrap">
          <ul><li>A</li></ul>
          </div>
            <p id="_">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p></p></div>
         <p>[SOURCE: ISO 7301:2011, 3.1]</p></div>
             </div>
           </body>
         </html>
    OUTPUT

    word = <<~OUTPUT
      <body lang="EN-US" link="blue" vlink="#954F72">
         <div class="WordSection2">
           <p class="page-break">
             <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
           </p>
           <div id="_" class="TOC">
             <p class="zzContents">Contents</p>
           </div>
           <p class="page-break">
             <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
           </p>
           <p class="zzSTDTitle1">INTERNATIONAL ELECTROTECHNICAL COMMISSION</p>
           <p class="zzSTDTitle1">____________</p>
           <p class="zzSTDTitle1"> </p>
           <p class="zzSTDTitle1">
             <b/>
           </p>
           <p class="zzSTDTitle1"> </p>
           <p> </p>
         </div>
         <p class="section-break">
           <br clear="all" class="section"/>
         </p>
         <div class="WordSection3">
           <div id="_">
             <h1>1<span style="mso-tab-count:1">  </span>Terms and definitions</h1>
             <p class="TermNum" id="paddy1">1.1</p>
             <p class="Terms" style="text-align:left;">paddy</p>
             <div class="termdefinition">
             <p id="_">&lt;rice&gt; rice retaining its husk after threshing</p>
             </div>
             <div id="_" class="example">
               <p><span class="example_label">EXAMPLE 1</span><span style="mso-tab-count:1">  </span>Foreign seeds, husks, bran, sand, dust.</p>
               <div class="ul_wrap">
               <ul>
                 <li>A</li>
               </ul>
             </div>
             </div>
             <div id="_" class="example">
               <p>
                 <span class="example_label">EXAMPLE 2</span>
                 <span style="mso-tab-count:1">  </span>
               </p>
               <div class="ul_wrap">
               <ul>
                 <li>A</li>
               </ul>
             </div>
             </div>
             <p>[SOURCE:
         ISO 7301:2011, 3.1, modified &#x2014; The term "cargo rice" is shown as deprecated, and Note 1 to entry is not included here]
       </p>
             <p class="TermNum" id="paddy">1.2</p>
             <p class="Terms" style="text-align:left;">paddy</p>
             <p class="AltTerms" style="text-align:left;">paddy rice</p>
             <p class="AltTerms" style="text-align:left;">rough rice</p>
             <p class="DeprecatedTerms" style="text-align:left;">DEPRECATED: cargo rice</p>
             <div class="termdefinition">
             <p id="_">rice retaining its husk after threshing</p>
             </div>
             <div id="_" class="Note">
               <p class="Note">Note 1 to entry: The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
             </div>
             <div id="_" class="Note">
               <p class="Note">Note 2 to entry:
               <div class="ul_wrap">
              <ul><li>A</li></ul>
              </div>
              <p id="_">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p></p>
             </div>
             <div id="_" class="example">
               <p>
                 <span class="example_label">EXAMPLE</span>
                 <span style="mso-tab-count:1">  </span>
               </p>
               <div class="ul_wrap">
               <ul>
                 <li>A</li>
               </ul>
             </div>
             </div>
             <p>[SOURCE:
         ISO 7301:2011, 3.1]
       </p>
           </div>
         </div>
         <br clear="all" style="page-break-before:left;mso-break-type:section-break"/>
         <div class="colophon"/>
       </body>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::Iec::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(IsoDoc::Iec::HtmlConvert.new({})
      .convert("test", presxml, true)))
      .to be_equivalent_to Xml::C14n.format(html)
    expect(Xml::C14n.format(IsoDoc::Iec::WordConvert.new({})
      .convert("test", presxml, true)
      .sub(%r{^.*<body}m, "<body")
      .sub(%r{</body>.*$}m, "</body>")))
      .to be_equivalent_to Xml::C14n.format(word)
  end

  it "processes IsoXML terms with multiple definitions" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <sections>
          <terms id="_terms_and_definitions" obligation="normative"><title>Terms and definitions</title>

      <term id="paddy1"><preferred>paddy</preferred>
      <domain>rice</domain>
      <definition><verbal-definition><p id="_eb29b35e-123e-4d1c-b50b-2714d41e747f">rice retaining its husk after threshing</p></verbal-definition></definition>
      <definition><verbal-definition>
        <p id="_eb29b35e-123e-4d1c-b50b-2714d41e747e">rice keeping its shell after threshing</p></verbal-definition>
        <p id="_eb29b35e-123e-4d1c-b50b-2714d41e747d">This is another paragraph</p></verbal-definition>
      </definition>
      </term>
      </terms>
      </sections>
      </iso-standard>
    INPUT
    presxml = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          #{PREFACE}</preface>
          <sections>
             <terms id="_" obligation="normative" displayorder="8">
                <title depth="1">
                   1
                   <tab/>
                   Terms and definitions
                </title>
                <term id="paddy1">
                   <name>1.1</name>
                   <preferred>paddy</preferred>
                   <definition>
                      <ol type="arabic">
                         <li>
                            <p id="_">&lt;rice&gt; rice retaining its husk after threshing</p>
                         </li>
                         <li>
                            <p id="_">rice keeping its shell after threshing</p>
                            <p id="_">This is another paragraph</p>
                         </li>
                      </ol>
                   </definition>
                </term>
             </terms>
          </sections>
      </iso-standard>
    INPUT
    html = <<~OUTPUT
      #{HTML_HDR}
          #{IEC_TITLE1}
               <div id="_"><h1>
             1
              
             Terms and definitions
          </h1>
                   <p class="TermNum" id="paddy1">1.1</p>
                   <p class="Terms" style="text-align:left;">paddy</p>
                   <div class="ol_wrap">
                      <ol type="1" class="arabic">
                         <li>
                            <p id="_">&lt;rice&gt; rice retaining its husk after threshing</p>
                         </li>
                         <li>
                            <p id="_">rice keeping its shell after threshing</p>
                            <p id="_">This is another paragraph</p>
                         </li>
                      </ol>
                   </div>
                </div>
             </div>
          </body>
       </html>
    OUTPUT
    word = <<~OUTPUT
      <div class="WordSection3">
          <div>
             <a name="_" id="_"/>
             <h1 class="main">
                1
                <span style="mso-tab-count:1">  </span>
                Terms and definitions
             </h1>
             <p class="TermNum">
                <a name="paddy1" id="paddy1"/>
                1.1
             </p>
             <p class="Terms" style="text-align:left;">paddy</p>
             <div class="termdefinition">
                <div class="ol_wrap">
                      <p class="MsoNormal">
                         <a name="_" id="_"/>
                         1)
                         <span style="mso-tab-count:1">  </span>
                         &lt;rice&gt; rice retaining its husk after threshing
                      </p>
                      <p class="MsoNormal">
                         <a name="_" id="_"/>
                         2)
                         <span style="mso-tab-count:1">  </span>
                         rice keeping its shell after threshing
                      </p>
                      <p class="MsoNormal">
                         <a name="_" id="_"/>
                         This is another paragraph
                      </p>
                </div>
             </div>
          </div>
       </div>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::Iec::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(IsoDoc::Iec::HtmlConvert.new({})
      .convert("test", presxml, true)))
      .to be_equivalent_to Xml::C14n.format(html)
    FileUtils.rm_f("test.doc")
    IsoDoc::Iec::WordConvert.new({})
      .convert("test", presxml, false)
    xml = Nokogiri::XML(File.read("test.doc")
      .sub(%r{^.*<body}m, "<body")
      .sub(%r{</body>.*$}m, "</body>"))
    xml = xml.at("//div[@class = 'WordSection3']")
    expect(Xml::C14n.format(strip_guid(xml.to_xml)))
      .to be_equivalent_to Xml::C14n.format(word)
  end
end
