require "spec_helper"

RSpec.describe IsoDoc do
  it "processes IsoXML terms" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <sections>
          <terms id="_terms_and_definitions" obligation="normative"><title>Terms and definitions</title>

      <term id="paddy1"><preferred><expression><name>paddy</name></expression></preferred>
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

      <source status="modified">
        <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011"><locality type="clause"><referenceFrom>3.1</referenceFrom></locality>ISO 7301:2011, 3.1</origin>
          <modification>
          <p id="_e73a417d-ad39-417d-a4c8-20e4e2529489">The term "cargo rice" is shown as deprecated, and Note 1 to entry is not included here</p>
        </modification>
      </source></term>

      <term id="paddy">
      <preferred><expression><name>paddy</name></expression></preferred>
      <admitted><expression><name>paddy rice</name></expression></admitted>
      <admitted><expression><name>rough rice</name></expression></admitted>
      <deprecates><expression><name>cargo rice</name></expression></deprecates>
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
      <source status="identical">
        <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011"><locality type="clause"><referenceFrom>3.1</referenceFrom></locality>ISO 7301:2011, 3.1</origin>
      </source></term>
      </terms>
      </sections>
      </iso-standard>
    INPUT
    presxml = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          #{PREFACE}</preface>
            <sections>
              <terms id="_" obligation="normative" displayorder="8">
                 <title id="_">Terms and definitions</title>
                 <fmt-title depth="1" id="_">
                    <span class="fmt-caption-label">
                       <semx element="autonum" source="_">1</semx>
                    </span>
                    <span class="fmt-caption-delim">
                       <tab/>
                    </span>
                    <semx element="title" source="_">Terms and definitions</semx>
                 </fmt-title>
                 <fmt-xref-label>
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="_">1</semx>
                 </fmt-xref-label>
                 <term id="paddy1">
                    <fmt-name id="_">
                       <span class="fmt-caption-label">
                          <semx element="autonum" source="_">1</semx>
                          <span class="fmt-autonum-delim">.</span>
                          <semx element="autonum" source="paddy1">1</semx>
                       </span>
                    </fmt-name>
                    <fmt-xref-label>
                       <semx element="autonum" source="_">1</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="paddy1">1</semx>
                    </fmt-xref-label>
                    <preferred id="_">
                       <expression>
                          <name>paddy</name>
                       </expression>
                    </preferred>
                    <fmt-preferred>
                       <p>
                          <semx element="preferred" source="_">
                             <strong>paddy</strong>
                          </semx>
                       </p>
                    </fmt-preferred>
                    <domain id="_">rice</domain>
                    <definition id="_">
                       <verbal-definition>
                          <p original-id="_">rice retaining its husk after threshing</p>
                       </verbal-definition>
                    </definition>
                    <fmt-definition id="_">
                       <semx element="definition" source="_">
                          <p id="_">
                             &lt;
                             <semx element="domain" source="_">rice</semx>
                             &gt; rice retaining its husk after threshing
                          </p>
                       </semx>
                    </fmt-definition>
                    <termexample id="_" autonum="1">
                       <fmt-name id="_">
                          <span class="fmt-caption-label">
                             <span class="fmt-element-name">EXAMPLE</span>
                             <semx element="autonum" source="_">1</semx>
                          </span>
                       </fmt-name>
                       <fmt-xref-label>
                          <span class="fmt-element-name">Example</span>
                          <semx element="autonum" source="_">1</semx>
                       </fmt-xref-label>
                       <fmt-xref-label container="paddy1">
                          <span class="fmt-xref-container">
                             <semx element="autonum" source="_">1</semx>
                             <span class="fmt-autonum-delim">.</span>
                             <semx element="autonum" source="paddy1">1</semx>
                          </span>
                          <span class="fmt-comma">,</span>
                          <span class="fmt-element-name">Example</span>
                          <semx element="autonum" source="_">1</semx>
                       </fmt-xref-label>
                       <p id="_">Foreign seeds, husks, bran, sand, dust.</p>
                       <ul>
                          <li id="_">
                             <fmt-name id="_">
                                <semx element="autonum" source="_">•</semx>
                             </fmt-name>
                             A
                          </li>
                       </ul>
                    </termexample>
                    <termexample id="_" autonum="2">
                       <fmt-name id="_">
                          <span class="fmt-caption-label">
                             <span class="fmt-element-name">EXAMPLE</span>
                             <semx element="autonum" source="_">2</semx>
                          </span>
                       </fmt-name>
                       <fmt-xref-label>
                          <span class="fmt-element-name">Example</span>
                          <semx element="autonum" source="_">2</semx>
                       </fmt-xref-label>
                       <fmt-xref-label container="paddy1">
                          <span class="fmt-xref-container">
                             <semx element="autonum" source="_">1</semx>
                             <span class="fmt-autonum-delim">.</span>
                             <semx element="autonum" source="paddy1">1</semx>
                          </span>
                          <span class="fmt-comma">,</span>
                          <span class="fmt-element-name">Example</span>
                          <semx element="autonum" source="_">2</semx>
                       </fmt-xref-label>
                       <ul>
                          <li id="_">
                             <fmt-name id="_">
                                <semx element="autonum" source="_">•</semx>
                             </fmt-name>
                             A
                          </li>
                       </ul>
                    </termexample>
                    <source status="modified" id="_">
                       <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011">
                          <locality type="clause">
                             <referenceFrom>3.1</referenceFrom>
                          </locality>
                          ISO 7301:2011, 3.1
                       </origin>
                       <modification id="_">
                          <p id="_">The term "cargo rice" is shown as deprecated, and Note 1 to entry is not included here</p>
                       </modification>
                    </source>
                    <fmt-termsource status="modified">
                       [SOURCE:
                       <semx element="source" source="_">
                          <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011" id="_">
                             <locality type="clause">
                                <referenceFrom>3.1</referenceFrom>
                             </locality>
                             ISO 7301:2011, 3.1
                          </origin>
                          <semx element="origin" source="_">
                             <fmt-origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011">
                                <locality type="clause">
                                   <referenceFrom>3.1</referenceFrom>
                                </locality>
                                ISO 7301:2011, 3.1
                             </fmt-origin>
                          </semx>
                          , modified —
                          <semx element="modification" source="_">The term "cargo rice" is shown as deprecated, and Note 1 to entry is not included here</semx>
                       </semx>
                       ]
                    </fmt-termsource>
                 </term>
                 <term id="paddy">
                    <fmt-name id="_">
                       <span class="fmt-caption-label">
                          <semx element="autonum" source="_">1</semx>
                          <span class="fmt-autonum-delim">.</span>
                          <semx element="autonum" source="paddy">2</semx>
                       </span>
                    </fmt-name>
                    <fmt-xref-label>
                       <semx element="autonum" source="_">1</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="paddy">2</semx>
                    </fmt-xref-label>
                    <preferred id="_">
                       <expression>
                          <name>paddy</name>
                       </expression>
                    </preferred>
                    <fmt-preferred>
                       <p>
                          <semx element="preferred" source="_">
                             <strong>paddy</strong>
                          </semx>
                       </p>
                    </fmt-preferred>
                    <admitted id="_">
                       <expression>
                          <name>paddy rice</name>
                       </expression>
                    </admitted>
                    <admitted id="_">
                       <expression>
                          <name>rough rice</name>
                       </expression>
                    </admitted>
                    <fmt-admitted>
                       <p>
                          <semx element="admitted" source="_">paddy rice</semx>
                       </p>
                       <p>
                          <semx element="admitted" source="_">rough rice</semx>
                       </p>
                    </fmt-admitted>
                    <deprecates id="_">
                       <expression>
                          <name>cargo rice</name>
                       </expression>
                    </deprecates>
                    <fmt-deprecates>
                       <p>
                          DEPRECATED:
                          <semx element="deprecates" source="_">cargo rice</semx>
                       </p>
                    </fmt-deprecates>
                    <definition id="_">
                       <verbal-definition>
                          <p original-id="_">rice retaining its husk after threshing</p>
                       </verbal-definition>
                    </definition>
                    <fmt-definition id="_">
                       <semx element="definition" source="_">
                          <p id="_">rice retaining its husk after threshing</p>
                       </semx>
                    </fmt-definition>
                    <termexample id="_" autonum="">
                       <fmt-name id="_">
                          <span class="fmt-caption-label">
                             <span class="fmt-element-name">EXAMPLE</span>
                          </span>
                       </fmt-name>
                       <fmt-xref-label>
                          <span class="fmt-element-name">Example</span>
                       </fmt-xref-label>
                       <fmt-xref-label container="paddy">
                          <span class="fmt-xref-container">
                             <semx element="autonum" source="_">1</semx>
                             <span class="fmt-autonum-delim">.</span>
                             <semx element="autonum" source="paddy">2</semx>
                          </span>
                          <span class="fmt-comma">,</span>
                          <span class="fmt-element-name">Example</span>
                       </fmt-xref-label>
                       <ul>
                          <li id="_">
                             <fmt-name id="_">
                                <semx element="autonum" source="_">•</semx>
                             </fmt-name>
                             A
                          </li>
                       </ul>
                    </termexample>
                    <termnote id="_" autonum="1">
                       <fmt-name id="_">
                          <span class="fmt-caption-label">Note 1 to entry</span>
                          <span class="fmt-label-delim">: </span>
                       </fmt-name>
                       <fmt-xref-label>
                          <span class="fmt-element-name">Note</span>
                          <semx element="autonum" source="_">1</semx>
                       </fmt-xref-label>
                       <fmt-xref-label container="paddy">
                          <span class="fmt-xref-container">
                             <semx element="autonum" source="_">1</semx>
                             <span class="fmt-autonum-delim">.</span>
                             <semx element="autonum" source="paddy">2</semx>
                          </span>
                          <span class="fmt-comma">,</span>
                          <span class="fmt-element-name">Note</span>
                          <semx element="autonum" source="_">1</semx>
                       </fmt-xref-label>
                       <p id="_">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
                    </termnote>
                    <termnote id="_" autonum="2">
                       <fmt-name id="_">
                          <span class="fmt-caption-label">Note 2 to entry</span>
                          <span class="fmt-label-delim">: </span>
                       </fmt-name>
                       <fmt-xref-label>
                          <span class="fmt-element-name">Note</span>
                          <semx element="autonum" source="_">2</semx>
                       </fmt-xref-label>
                       <fmt-xref-label container="paddy">
                          <span class="fmt-xref-container">
                             <semx element="autonum" source="_">1</semx>
                             <span class="fmt-autonum-delim">.</span>
                             <semx element="autonum" source="paddy">2</semx>
                          </span>
                          <span class="fmt-comma">,</span>
                          <span class="fmt-element-name">Note</span>
                          <semx element="autonum" source="_">2</semx>
                       </fmt-xref-label>
                       <ul>
                          <li id="_">
                             <fmt-name id="_">
                                <semx element="autonum" source="_">•</semx>
                             </fmt-name>
                             A
                          </li>
                       </ul>
                       <p id="_">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
                    </termnote>
                    <source status="identical" id="_">
                       <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011">
                          <locality type="clause">
                             <referenceFrom>3.1</referenceFrom>
                          </locality>
                          ISO 7301:2011, 3.1
                       </origin>
                    </source>
                    <fmt-termsource status="identical">
                       [SOURCE:
                       <semx element="source" source="_">
                          <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011" id="_">
                             <locality type="clause">
                                <referenceFrom>3.1</referenceFrom>
                             </locality>
                             ISO 7301:2011, 3.1
                          </origin>
                          <semx element="origin" source="_">
                             <fmt-origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011">
                                <locality type="clause">
                                   <referenceFrom>3.1</referenceFrom>
                                </locality>
                                ISO 7301:2011, 3.1
                             </fmt-origin>
                          </semx>
                       </semx>
                       ]
                    </fmt-termsource>
                 </term>
              </terms>
           </sections>
        </iso-standard>
    INPUT
    html = <<~OUTPUT
      #{HTML_HDR}
          #{IEC_TITLE1}
                           <div id="_">
                    <h1>1  Terms and definitions</h1>
                    <p class="TermNum" id="paddy1">1.1</p>
                    <p class="Terms" style="text-align:left;"><b>paddy</b></p>
                    <p id="_">&lt;rice&gt;  rice retaining its husk after threshing</p>
                    <div id="_" class="example">
                       <p>
                          <span class="example_label">EXAMPLE 1</span>
                            Foreign seeds, husks, bran, sand, dust.
                       </p>
                       <div class="ul_wrap">
                          <ul>
                             <li id="_">A</li>
                          </ul>
                       </div>
                    </div>
                    <div id="_" class="example">
                       <p>
                          <span class="example_label">EXAMPLE 2</span>
                           
                       </p>
                       <div class="ul_wrap">
                          <ul>
                             <li id="_">A</li>
                          </ul>
                       </div>
                    </div>
                    <p>[SOURCE: ISO 7301:2011, 3.1, modified
             —
            The term "cargo rice" is shown as deprecated, and Note 1 to entry is not included here]</p>
                    <p class="TermNum" id="paddy">1.2</p>
                    <p class="Terms" style="text-align:left;"><b>paddy</b></p>
                    <p class="AltTerms" style="text-align:left;">paddy rice</p>
                    <p class="AltTerms" style="text-align:left;">rough rice</p>
                    <p class="DeprecatedTerms" style="text-align:left;">DEPRECATED: cargo rice</p>
                    <p id="_">rice retaining its husk after threshing</p>
                    <div id="_" class="example">
                       <p>
                          <span class="example_label">EXAMPLE</span>
                           
                       </p>
                       <div class="ul_wrap">
                          <ul>
                             <li id="_">A</li>
                          </ul>
                       </div>
                    </div>
                    <div id="_" class="Note">
                       <p>
                          <span class="termnote_label">Note 1 to entry: </span>
                          The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.
                       </p>
                    </div>
                    <div id="_" class="Note">
                       <p>
                          <span class="termnote_label">Note 2 to entry: </span>
                       </p>
                       <div class="ul_wrap">
                          <ul>
                             <li id="_">A</li>
                          </ul>
                       </div>
                       <p id="_">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
                    </div>
                    <p>[SOURCE: ISO 7301:2011, 3.1]</p>
                 </div>
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
                 <h1>
                    1
                    <span style="mso-tab-count:1">  </span>
                    Terms and definitions
                 </h1>
                 <p class="TermNum" id="paddy1">1.1</p>
                 <p class="Terms" style="text-align:left;"><b>paddy</b></p>
                 <p class="Definition" id="_">&lt;rice&gt;  rice retaining its husk after threshing</p>
                 <div id="_" class="example">
                    <p>
                       <span class="example_label">EXAMPLE 1</span>
                       <span style="mso-tab-count:1">  </span>
                       Foreign seeds, husks, bran, sand, dust.
                    </p>
                    <div class="ul_wrap">
                       <ul>
                          <li id="_">A</li>
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
                          <li id="_">A</li>
                       </ul>
                    </div>
                 </div>
                 <p>[SOURCE: ISO 7301:2011, 3.1, modified
             —
            The term "cargo rice" is shown as deprecated, and Note 1 to entry is not included here]</p>
                 <p class="TermNum" id="paddy">1.2</p>
                 <p class="Terms" style="text-align:left;"><b>paddy</b></p>
                 <p class="AltTerms" style="text-align:left;">paddy rice</p>
                 <p class="AltTerms" style="text-align:left;">rough rice</p>
                 <p class="DeprecatedTerms" style="text-align:left;">DEPRECATED: cargo rice</p>
                 <p class="Definition" id="_">rice retaining its husk after threshing</p>
                 <div id="_" class="example">
                    <p>
                       <span class="example_label">EXAMPLE</span>
                       <span style="mso-tab-count:1">  </span>
                    </p>
                    <div class="ul_wrap">
                       <ul>
                          <li id="_">A</li>
                       </ul>
                    </div>
                 </div>
                 <div id="_" class="Note">
                    <p class="Note">
                       <span class="termnote_label">Note 1 to entry: </span>
                       The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.
                    </p>
                 </div>
                 <div id="_" class="Note">
                    <p class="Note">
                       <span class="termnote_label">Note 2 to entry: </span>
                    </p>
                    <div class="ul_wrap">
                       <ul>
                          <li id="_">A</li>
                       </ul>
                    </div>
                    <p id="_">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
                 </div>
                 <p>[SOURCE: ISO 7301:2011, 3.1]</p>
              </div>
           </div>
           <br clear="all" style="page-break-before:left;mso-break-type:section-break"/>
           <div class="colophon"/>
        </body>
    OUTPUT
    pres_output = IsoDoc::Iec::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(pres_output)))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(IsoDoc::Iec::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Xml::C14n.format(html)
    expect(Xml::C14n.format(strip_guid(IsoDoc::Iec::WordConvert.new({})
      .convert("test", pres_output, true)
      .sub(%r{^.*<body}m, "<body")
      .sub(%r{</body>.*$}m, "</body>"))))
      .to be_equivalent_to Xml::C14n.format(word)
  end
end
