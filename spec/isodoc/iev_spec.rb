require "spec_helper"

RSpec.describe IsoDoc do
  it "processes introductions under IEV" do
    input = <<~INPUT
            <iso-standard xmlns="http://riboseinc.com/isoxml">
            <bibdata>
            <docidentifier type="iso">IEC/PWI 60050-871 ED 2</docidentifier>
      <docnumber>60050</docnumber>
            </bibdata>
            <preface>
            <foreword obligation="informative">
               <title>Foreword</title>
               <p id="A">This is a preamble</p>
             </foreword>
              <introduction id="B" obligation="informative"><title>Introduction</title>
              <clause id="C" inline-header="false" obligation="informative">
               <title>Introduction Subsection</title>
             </clause>
             </introduction></preface><sections/>
             </iso-standard>
    INPUT

    presxml = <<~OUTPUT
             <iso-standard xmlns='http://riboseinc.com/isoxml' type="presentation">
        <bibdata>
          <docidentifier type='iso'>IEC/PWI 60050-871 ED 2</docidentifier>
          <docnumber>60050</docnumber>
        </bibdata>
        #{PREFACE}
             <foreword obligation="informative" displayorder="8" id="_">
                <title id="_">Foreword</title>
                <fmt-title depth="1">
                   <semx element="title" source="_">Foreword</semx>
                </fmt-title>
                <p id="A">This is a preamble</p>
             </foreword>
             <introduction id="B" obligation="informative" displayorder="9">
                <title id="_">Introduction</title>
                <fmt-title depth="1">
                   <semx element="title" source="_">Introduction</semx>
                </fmt-title>
                <clause id="C" inline-header="false" obligation="informative">
                   <title id="_">Introduction Subsection</title>
                   <fmt-title depth="2">
                      <semx element="title" source="_">Introduction Subsection</semx>
                   </fmt-title>
                </clause>
             </introduction>
          </preface>
          <sections/>
       </iso-standard>
    OUTPUT

    html = <<~OUTPUT
             #{HTML_HDR}
            <div id="_">
              <h1 class='ForewordTitle'>Foreword</h1>
              <p id='A'>This is a preamble</p>
            </div>
            <br/>
            <div class='Section3' id='B'>
              <h1 class='IntroTitle'>
                Introduction
              </h1>
              <div id='C'>
                <h2>Introduction Subsection</h2>
              </div>
            </div>
            #{IEC_TITLE1}
          </div>
        </body>
      </html>
    OUTPUT
    pres_output = IsoDoc::Iec::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(pres_output
      .sub(%r{<localized-strings>.*</localized-strings>}m, ""))))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(IsoDoc::Iec::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Xml::C14n.format(html)
  end

  it "processes bibliographies under IEV" do
    input = <<~INPUT
      <iec-standard xmlns='https://www.metanorma.org/ns/iec'>
              <bibdata type='standard'>
                <docidentifier type='iso'>IEC 60050 ED 1</docidentifier>
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
                  <stage>60</stage>
                  <substage>60</substage>
                </status>
                <copyright>
                  <from>2020</from>
                  <owner>
                    <organization>
                      <name>International Electrotechnical Commission</name>
                      <abbreviation>IEC</abbreviation>
                    </organization>
                  </owner>
                </copyright>
                <ext>
                  <doctype>international-standard</doctype>
                  <editorialgroup>
                    <technical-committee/>
                    <subcommittee/>
                    <workgroup/>
                  </editorialgroup>
                  <structuredidentifier>
                    <project-number>IEC 60050</project-number>
                  </structuredidentifier>
                </ext>
              </bibdata>
              <sections> </sections>
              <bibliography>
                <references obligation='informative' normative="true" id="X">
                  <title>Normative References</title>
                  <p id='_'>There are no normative references in this document.</p>
                  <bibitem id='A'>
                    <formattedref format='application/x-isodoc+xml'>
                      <em>TITLE</em>
                    </formattedref>
                    <docidentifier>B</docidentifier>
                  </bibitem>
                </references>
                <references id='Y' obligation='informative' normative="false">
                  <title>Bibliography</title>
                  <p id='_'>There are no normative references in this document.</p>
                  <bibitem id='A'>
                    <formattedref format='application/x-isodoc+xml'>
                      <em>TITLE</em>
                    </formattedref>
                    <docidentifier>B</docidentifier>
                  </bibitem>
                </references>

              </bibliography>
            </iec-standard>
    INPUT
    presxml = <<~OUTPUT
      <iec-standard xmlns='https://www.metanorma.org/ns/iec' type="presentation">
        <bibdata type='standard'>
          <docidentifier type='iso'>IEC 60050 ED 1</docidentifier>
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
          <language current="true">en</language>
          <script current="true">Latn</script>
          <status>
            <stage language="">60</stage>
                  <stage language='fr'>Norme internationale</stage>
                  <stage language='en'>International Standard</stage>
            <substage>60</substage>
          </status>
          <copyright>
            <from>2020</from>
            <owner>
              <organization>
                <name>International Electrotechnical Commission</name>
                <abbreviation>IEC</abbreviation>
              </organization>
            </owner>
          </copyright>
          <ext>
            <doctype language=''>international-standard</doctype>
            <doctype language='fr'>Norme internationale</doctype>
            <doctype language='en'>International Standard</doctype>
             <editorialgroup identifier='//'>
              <technical-committee/>
              <subcommittee/>
              <workgroup/>
            </editorialgroup>
            <structuredidentifier>
              <project-number>IEC 60050</project-number>
            </structuredidentifier>
          </ext>
        </bibdata>
        #{PREFACE}</preface>
                 <sections>
             <references obligation="informative" normative="true" id="X" displayorder="8">
                <title id="_">Normative References</title>
                <fmt-title depth="1">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="X">1</semx>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">Normative References</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">Clause</span>
                   <semx element="autonum" source="X">1</semx>
                </fmt-xref-label>
                <p id="_">There are no normative references in this document.</p>
                <bibitem id="A">
                   <formattedref format="application/x-isodoc+xml">
                      <em>TITLE</em>
                   </formattedref>
                   <docidentifier>B</docidentifier>
                   <docidentifier scope="biblio-tag">B</docidentifier>
                   <biblio-tag>B, </biblio-tag>
                </bibitem>
             </references>
          </sections>
          <bibliography>
             <references id="Y" obligation="informative" normative="false" displayorder="9">
                <title id="_">Bibliography</title>
                <fmt-title depth="1">
                   <semx element="title" source="_">Bibliography</semx>
                </fmt-title>
                <p id="_">There are no normative references in this document.</p>
                <bibitem id="A">
                   <formattedref format="application/x-isodoc+xml">
                      <em>TITLE</em>
                   </formattedref>
                   <docidentifier type="metanorma-ordinal">[1]</docidentifier>
                   <docidentifier>B</docidentifier>
                   <docidentifier scope="biblio-tag">B</docidentifier>
                   <biblio-tag>
                      [1]
                      <tab/>
                      B,
                   </biblio-tag>
                </bibitem>
             </references>
          </bibliography>
       </iec-standard>
    OUTPUT
    html = <<~OUTPUT
       #{HTML_HDR}
            #{IEC_TITLE1}
            <div>
        <h1>1&#160; Normative References</h1>
        <p id='_'>There are no normative references in this document.</p>
      </div>
          </div>
        </body>
      </html>
    OUTPUT
    pres_output = IsoDoc::Iec::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(pres_output
      .sub(%r{<localized-strings>.*</localized-strings>}m, ""))))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(IsoDoc::Iec::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Xml::C14n.format(html)
  end

  it "processes IEV terms" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
           <bibdata type='standard'>
                 <docidentifier type='ISO'>IEC 60050-192 ED 1</docidentifier>
                 <docnumber>60050</docnumber>
          </bibdata>
          <sections>
          <clause id="_terms_and_definitions" obligation="normative"><title>Terms and definitions</title>
          <terms id="_general" obligation="normative"><title>General</title>
      <term id="paddy1"><preferred><expression><name>paddy</name></expression></preferred>
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
      <term id="paddy"><preferred><expression><name>paddy</name></expression></preferred>
      <admitted><expression><name>paddy rice</name></expression></admitted>
      <admitted><expression><name>rough rice</name></expression></admitted>
      <deprecates><expression><name>cargo rice</name></expression></deprecates>
      <domain>rice</domain>
      <definition><verbal-definition><p id="_eb29b35e-123e-4d1c-b50b-2714d41e747f">rice retaining its husk after threshing</p></verbal-definition></definition>
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
        <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011"><locality type="clause"><referenceFrom>3.1</referenceFrom></locality>ISO 7301:2011, 3.1</origin>
      </termsource></term>
      </terms>
      </clause>
      </sections>
      </iso-standard>
    INPUT

    presxml = <<~INPUT
          <?xml version='1.0'?>
          <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
           <bibdata type='standard'>
                 <docidentifier type='ISO'>IEC 60050-192 ED 1</docidentifier>
                 <docnumber>60050</docnumber>
          </bibdata>
          #{PREFACE}</preface>
          <sections>
             <clause id="_" obligation="normative" displayorder="8">
                <title id="_">Terms and definitions</title>
                <fmt-title depth="1">
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
                <terms id="_" obligation="normative">
                   <title id="_">General</title>
                   <fmt-title>
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="_">192-01</semx>
                      </span>
                      <span class="fmt-caption-delim"> </span>
                      <semx element="title" source="_">General</semx>
                   </fmt-title>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Section</span>
                      <semx element="autonum" source="_">192-01</semx>
                   </fmt-xref-label>
                   <term id="paddy1">
                      <fmt-name>
                         <span class="fmt-caption-label">
                            <semx element="autonum" source="_">192-01</semx>
                            <span class="fmt-autonum-delim">-</span>
                            <semx element="autonum" source="paddy1">01</semx>
                         </span>
                      </fmt-name>
                      <fmt-xref-label>
                         <semx element="autonum" source="_">192-01</semx>
                         <span class="fmt-autonum-delim">-</span>
                         <semx element="autonum" source="paddy1">01</semx>
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
                      <definition id="_">
                         <verbal-definition>
                            <p original-id="_">rice retaining its husk after threshing</p>
                         </verbal-definition>
                      </definition>
                      <fmt-definition>
                         <semx element="definition" source="_">
                            <p id="_">rice retaining its husk after threshing</p>
                         </semx>
                      </fmt-definition>
                      <termexample id="_" autonum="1">
                         <fmt-name>
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
                               <semx element="autonum" source="_">192-01</semx>
                               <span class="fmt-autonum-delim">-</span>
                               <semx element="autonum" source="paddy1">01</semx>
                            </span>
                            <span class="fmt-comma">,</span>
                            <span class="fmt-element-name">Example</span>
                            <semx element="autonum" source="_">1</semx>
                         </fmt-xref-label>
                         <p id="_">Foreign seeds, husks, bran, sand, dust.</p>
                         <ul>
                            <li>A</li>
                         </ul>
                      </termexample>
                      <termexample id="_" autonum="2">
                         <fmt-name>
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
                               <semx element="autonum" source="_">192-01</semx>
                               <span class="fmt-autonum-delim">-</span>
                               <semx element="autonum" source="paddy1">01</semx>
                            </span>
                            <span class="fmt-comma">,</span>
                            <span class="fmt-element-name">Example</span>
                            <semx element="autonum" source="_">2</semx>
                         </fmt-xref-label>
                         <ul>
                            <li>A</li>
                         </ul>
                      </termexample>
                      <termsource status="modified" id="_">
                         <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011">
                            <locality type="clause">
                               <referenceFrom>3.1</referenceFrom>
                            </locality>
                            ISO 7301:2011, 3.1
                         </origin>
                         <modification>
                            <p original-id="_">The term "cargo rice" is shown as deprecated, and Note 1 to entry is not included here</p>
                         </modification>
                      </termsource>
                      <fmt-termsource status="modified">
                         SOURCE:
                         <semx element="termsource" source="_">
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
                      </fmt-termsource>
                   </term>
                   <term id="paddy">
                      <fmt-name>
                         <span class="fmt-caption-label">
                            <semx element="autonum" source="_">192-01</semx>
                            <span class="fmt-autonum-delim">-</span>
                            <semx element="autonum" source="paddy">02</semx>
                         </span>
                      </fmt-name>
                      <fmt-xref-label>
                         <semx element="autonum" source="_">192-01</semx>
                         <span class="fmt-autonum-delim">-</span>
                         <semx element="autonum" source="paddy">02</semx>
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
                      <domain>rice</domain>
                      <definition id="_">
                         <verbal-definition>
                            <p original-id="_">rice retaining its husk after threshing</p>
                         </verbal-definition>
                      </definition>
                      <fmt-definition>
                         <semx element="definition" source="_">
                            <p id="_">rice retaining its husk after threshing</p>
                         </semx>
                      </fmt-definition>
                      <termexample id="_" autonum="">
                         <fmt-name>
                            <span class="fmt-caption-label">
                               <span class="fmt-element-name">EXAMPLE</span>
                            </span>
                         </fmt-name>
                         <fmt-xref-label>
                            <span class="fmt-element-name">Example</span>
                         </fmt-xref-label>
                         <fmt-xref-label container="paddy">
                            <span class="fmt-xref-container">
                               <semx element="autonum" source="_">192-01</semx>
                               <span class="fmt-autonum-delim">-</span>
                               <semx element="autonum" source="paddy">02</semx>
                            </span>
                            <span class="fmt-comma">,</span>
                            <span class="fmt-element-name">Example</span>
                         </fmt-xref-label>
                         <ul>
                            <li>A</li>
                         </ul>
                      </termexample>
                      <termnote id="_" autonum="1">
                         <fmt-name>
                            <span class="fmt-caption-label">Note 1 to entry</span>
                            <span class="fmt-label-delim">: </span>
                         </fmt-name>
                         <fmt-xref-label>
                            <span class="fmt-element-name">Note</span>
                            <semx element="autonum" source="_">1</semx>
                         </fmt-xref-label>
                         <fmt-xref-label container="paddy">
                            <span class="fmt-xref-container">
                               <semx element="autonum" source="_">192-01</semx>
                               <span class="fmt-autonum-delim">-</span>
                               <semx element="autonum" source="paddy">02</semx>
                            </span>
                            <span class="fmt-comma">,</span>
                            <span class="fmt-element-name">Note</span>
                            <semx element="autonum" source="_">1</semx>
                         </fmt-xref-label>
                         <p id="_">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
                      </termnote>
                      <termnote id="_" autonum="2">
                         <fmt-name>
                            <span class="fmt-caption-label">Note 2 to entry</span>
                            <span class="fmt-label-delim">: </span>
                         </fmt-name>
                         <fmt-xref-label>
                            <span class="fmt-element-name">Note</span>
                            <semx element="autonum" source="_">2</semx>
                         </fmt-xref-label>
                         <fmt-xref-label container="paddy">
                            <span class="fmt-xref-container">
                               <semx element="autonum" source="_">192-01</semx>
                               <span class="fmt-autonum-delim">-</span>
                               <semx element="autonum" source="paddy">02</semx>
                            </span>
                            <span class="fmt-comma">,</span>
                            <span class="fmt-element-name">Note</span>
                            <semx element="autonum" source="_">2</semx>
                         </fmt-xref-label>
                         <ul>
                            <li>A</li>
                         </ul>
                         <p id="_">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
                      </termnote>
                      <termsource status="identical" id="_">
                         <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011">
                            <locality type="clause">
                               <referenceFrom>3.1</referenceFrom>
                            </locality>
                            ISO 7301:2011, 3.1
                         </origin>
                      </termsource>
                      <fmt-termsource status="identical">
                         SOURCE:
                         <semx element="termsource" source="_">
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
                      </fmt-termsource>
                   </term>
                </terms>
             </clause>
          </sections>
       </iso-standard>
    INPUT

    html = <<~OUTPUT
      #{HTML_HDR}
                 #{IEC_TITLE1}
                              <div id='_'>
                                                 <h1>1  Terms and definitions</h1>
                   <br/>
                   <div id="_">
                      <h2 class="zzSTDTitle2">
                         <b>192-01 General</b>
                      </h2>
                      <p class="TermNum" id="paddy1">192-01-01</p>
                      <p class="Terms" style="text-align:left;">
                         <b>paddy</b>
                      </p>
                      <p id="_">rice retaining its husk after threshing</p>
                      <div id="_" class="example">
                         <p>
                            <span class="example_label">EXAMPLE 1</span>
                              Foreign seeds, husks, bran, sand, dust.
                         </p>
                         <div class="ul_wrap">
                            <ul>
                               <li>A</li>
                            </ul>
                         </div>
                      </div>
                      <div id="_" class="example">
                         <p>
                            <span class="example_label">EXAMPLE 2</span>
                             
                         </p>
                         <div class="ul_wrap">
                            <ul>
                               <li>A</li>
                            </ul>
                         </div>
                      </div>
                      <p>SOURCE: ISO 7301:2011, 3.1, modified — The term "cargo rice" is shown as deprecated, and Note 1 to entry is not included here</p>
                      <p class="TermNum" id="paddy">192-01-02</p>
                      <p class="Terms" style="text-align:left;">
                         <b>paddy</b>
                      </p>
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
                               <li>A</li>
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
                               <li>A</li>
                            </ul>
                         </div>
                         <p id="_">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
                      </div>
                      <p>SOURCE: ISO 7301:2011, 3.1</p>
                   </div>
                </div>
             </div>
          </body>
       </html>
    OUTPUT
    pres_output = IsoDoc::Iec::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(pres_output
      .sub(%r{<localized-strings>.*</localized-strings>}m, ""))))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(IsoDoc::Iec::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Xml::C14n.format(html)
  end

  it "populates Word template with terms reference labels" do
    FileUtils.rm_f "test.doc"
    FileUtils.rm_f "test.html"
    input = <<~INPUT
              <iso-standard xmlns="http://riboseinc.com/isoxml">
              <bibdata type='standard'>
                 <docidentifier type='ISO'>IEC 60050-192 ED 1</docidentifier>
                 <docnumber>60050</docnumber>
          </bibdata>
          <sections>
          <clause id="_terms_and_definitions" obligation="normative" displayorder="1"><title>Terms and definitions</title>
          <terms id="_general" obligation="normative"><title>General</title>
      <term id="paddy1"><preferred><expression><name>paddy</name></expression></preferred>
      <definition><verbal-definition><p id="_eb29b35e-123e-4d1c-b50b-2714d41e747f">rice retaining its husk after threshing</p></verbal-definition></definition>
      <termsource status="modified">
        <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011"><locality type="clause"><referenceFrom>3.1</referenceFrom></locality>ISO 7301:2011, 3.1</origin>
          <modification>
          <p id="_e73a417d-ad39-417d-a4c8-20e4e2529489">The term "cargo rice" is shown as deprecated, and Note 1 to entry is not included here</p>
        </modification>
      </termsource></term>
      </terms>
      </clause>
      </sections>
      </iso-standard>
    INPUT
    presxml = <<~OUTPUT
          <iso-standard xmlns='http://riboseinc.com/isoxml' type="presentation">
        <bibdata type='standard'>
          <docidentifier type='ISO'>IEC 60050-192 ED 1</docidentifier>
          <docnumber>60050</docnumber>
        </bibdata>
        #{PREFACE}</preface>
          <sections>
             <clause id="_" obligation="normative" displayorder="8">
                <title id="_">Terms and definitions</title>
                <fmt-title depth="1">
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
                <terms id="_" obligation="normative">
                   <title id="_">General</title>
                   <fmt-title>
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="_">192-01</semx>
                      </span>
                      <span class="fmt-caption-delim"> </span>
                      <semx element="title" source="_">General</semx>
                   </fmt-title>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Section</span>
                      <semx element="autonum" source="_">192-01</semx>
                   </fmt-xref-label>
                   <term id="paddy1">
                      <fmt-name>
                         <span class="fmt-caption-label">
                            <semx element="autonum" source="_">192-01</semx>
                            <span class="fmt-autonum-delim">-</span>
                            <semx element="autonum" source="paddy1">01</semx>
                         </span>
                      </fmt-name>
                      <fmt-xref-label>
                         <semx element="autonum" source="_">192-01</semx>
                         <span class="fmt-autonum-delim">-</span>
                         <semx element="autonum" source="paddy1">01</semx>
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
                      <definition id="_">
                         <verbal-definition>
                            <p original-id="_">rice retaining its husk after threshing</p>
                         </verbal-definition>
                      </definition>
                      <fmt-definition>
                         <semx element="definition" source="_">
                            <p id="_">rice retaining its husk after threshing</p>
                         </semx>
                      </fmt-definition>
                      <termsource status="modified" id="_">
                         <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011">
                            <locality type="clause">
                               <referenceFrom>3.1</referenceFrom>
                            </locality>
                            ISO 7301:2011, 3.1
                         </origin>
                         <modification>
                            <p original-id="_">The term "cargo rice" is shown as deprecated, and Note 1 to entry is not included here</p>
                         </modification>
                      </termsource>
                      <fmt-termsource status="modified">
                         SOURCE:
                         <semx element="termsource" source="_">
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
                      </fmt-termsource>
                   </term>
                </terms>
             </clause>
          </sections>
       </iso-standard>
    OUTPUT
    pres_output = IsoDoc::Iec::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(pres_output
      .sub(%r{<localized-strings>.*</localized-strings>}m, ""))))
      .to be_equivalent_to Xml::C14n.format(presxml)
    IsoDoc::Iec::WordConvert.new({}).convert("test", pres_output, false)
    word = File.read("test.doc")
      .sub(/^.*<div class="WordSection3">/m, '<div class="WordSection3">')
      .sub(%r{<br clear="all" style="page-break-before:left;mso-break-type:section-break"/>.*$}m, "")
    expect(Xml::C14n.format(strip_guid(word)))
      .to be_equivalent_to Xml::C14n.format(<<~OUTPUT)
      <div class='WordSection3'>
           <div>
             <a name='_' id='_'/>
             <h1 class='main'>
               1
               <span style='mso-tab-count:1'>&#xA0; </span>
               Terms and definitions
             </h1>
             <p class='MsoNormal'>
               <br clear='all' style='mso-special-character:line-break;page-break-before:always'/>
             </p>
             <div>
               <a name='_' id='_'/>
               <h2 class='zzSTDTitle2'>
                 <b>192-01 General</b>
               </h2>
               <p class='TermNum'>
                 <a name='paddy1' id='paddy1'/>
                 192-01-01
               </p>
               <p class='Terms' style='text-align:left;'><b>paddy</b></p>
               <p class='Definition'>
                 <a name='_' id='_'/>
                 rice retaining its husk after threshing
               </p>
               <p class='MsoNormal'>
                 SOURCE: ISO 7301:2011, 3.1, modified &#x2014; The term "cargo rice" is shown as deprecated, and
                 Note 1 to entry is not included here
               </p>
             </div>
           </div>
         </div>
    OUTPUT
  end

  it "convert termbase references to the current document to xrefs" do
    input = <<~INPUT
                    <iso-standard xmlns="http://riboseinc.com/isoxml">
                    <bibdata type='standard'>
                       <docidentifier type='ISO'>IEC 60050-192 ED 1</docidentifier>
                       <docnumber>60050</docnumber>
                       <ext>
                          <doctype>international-standard</doctype>
                                              <horizontal>false</horizontal>
                          <structuredidentifier>
                          <project-number part="192">IEC 60050</project-number>
                          </structuredidentifier>
                          <stagename>International standard</stagename>
                          </ext>
                </bibdata>
                <sections>
                <clause id="_terms_and_definitions" obligation="normative" displayorder="1"><title>Terms and definitions</title>
                <terms id="_general" obligation="normative"><title>General</title>
            <term id="term-durability"><preferred><expression><name>durability</name></expression><field-of-application>of an item</field-of-application></preferred>
            <definition><verbaldefinition><p id="_eb29b35e-123e-4d1c-b50b-2714d41e747f">rice retaining its husk after threshing</p></verbaldefinition></definition>
            <termnote id="_5f49cfad-e57e-5029-78cf-5b7e3e10a3b3">
      <p id="_8c830e60-8f09-73a2-6393-2a27d9c5b1ce">Dependability includes availability (<concept><refterm>192-01-02</refterm><renderterm>192-01-02</renderterm><termref base="IEV" target="192-01-02"/></concept>, <concept><refterm>191-01-02</refterm><renderterm>191-01-02</renderterm><termref base="IEV" target="191-01-02"/></concept>)</p>
            </termnote>
            </term>
            <term id="term-sub-item"><preferred><expression><name>sub item</name></expression></preferred><definition><verbal-definition><p id="_6952e988-8803-159d-a32e-57147fbf3d86">part of the subject being considered</p></verbal-definition></definition>
            </term>
            </terms>
            </clause>
            </sections>
            </iso-standard>
    INPUT
    presxml = <<~PRESXML
        <?xml version='1.0'?>
          <iso-standard xmlns='http://riboseinc.com/isoxml' type='presentation'>
        <bibdata type='standard'>
          <docidentifier type='ISO'>IEC 60050-192 ED 1</docidentifier>
          <docnumber>60050</docnumber>
          <ext>
            <doctype language=''>international-standard</doctype>
            <doctype language='fr'>Norme internationale</doctype>
            <doctype language='en'>International Standard</doctype>
            <horizontal>false</horizontal>
            <structuredidentifier>
              <project-number part='192'>IEC 60050</project-number>
            </structuredidentifier>
            <stagename>International standard</stagename>
          </ext>
        </bibdata>
        #{PREFACE}</preface>
          <sections>
             <clause id="_" obligation="normative" displayorder="8">
                <title id="_">Terms and definitions</title>
                <fmt-title depth="1">
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
                <terms id="_" obligation="normative">
                   <title id="_">General</title>
                   <fmt-title>
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="_">192-01</semx>
                      </span>
                      <span class="fmt-caption-delim"> </span>
                      <semx element="title" source="_">General</semx>
                   </fmt-title>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Section</span>
                      <semx element="autonum" source="_">192-01</semx>
                   </fmt-xref-label>
                   <term id="term-durability">
                      <fmt-name>
                         <span class="fmt-caption-label">
                            <semx element="autonum" source="_">192-01</semx>
                            <span class="fmt-autonum-delim">-</span>
                            <semx element="autonum" source="term-durability">01</semx>
                         </span>
                      </fmt-name>
                      <fmt-xref-label>
                         <semx element="autonum" source="_">192-01</semx>
                         <span class="fmt-autonum-delim">-</span>
                         <semx element="autonum" source="term-durability">01</semx>
                      </fmt-xref-label>
                      <preferred id="_">
                         <expression>
                            <name>durability</name>
                         </expression>
                         <field-of-application id="_">of an item</field-of-application>
                      </preferred>
                      <fmt-preferred>
                         <p>
                            <semx element="preferred" source="_">
                               <strong>durability</strong>
                               <span class="fmt-designation-field">
                                  , &lt;
                                  <semx element="field-of-application" source="_">of an item</semx>
                                  &gt;
                               </span>
                            </semx>
                         </p>
                      </fmt-preferred>
                      <definition id="_">
                         <verbaldefinition>
                            <p original-id="_">rice retaining its husk after threshing</p>
                         </verbaldefinition>
                      </definition>
                      <fmt-definition>
                         <semx element="definition" source="_">
                            <verbaldefinition>
                               <p id="_">rice retaining its husk after threshing</p>
                            </verbaldefinition>
                         </semx>
                      </fmt-definition>
                      <termnote id="_" autonum="1">
                         <fmt-name>
                            <span class="fmt-caption-label">Note 1 to entry</span>
                            <span class="fmt-label-delim">: </span>
                         </fmt-name>
                         <fmt-xref-label>
                            <span class="fmt-element-name">Note</span>
                            <semx element="autonum" source="_">1</semx>
                         </fmt-xref-label>
                         <fmt-xref-label container="term-durability">
                            <span class="fmt-xref-container">
                               <semx element="autonum" source="_">192-01</semx>
                               <span class="fmt-autonum-delim">-</span>
                               <semx element="autonum" source="term-durability">01</semx>
                            </span>
                            <span class="fmt-comma">,</span>
                            <span class="fmt-element-name">Note</span>
                            <semx element="autonum" source="_">1</semx>
                         </fmt-xref-label>
                         <p id="_">
                            Dependability includes availability (
                            <concept id="_">
                               <refterm>192-01-02</refterm>
                               <renderterm>192-01-02</renderterm>
                               <termref base="IEV" target="192-01-02"/>
                            </concept>
                            <fmt-concept>
                               <semx element="concept" source="_">
                                  <em>192-01-02</em>
                                  (
                                  <fmt-xref target="term-sub-item">
                                     <span class="citesec">
                                        <semx element="autonum" source="_">192-01</semx>
                                        <span class="fmt-autonum-delim">-</span>
                                        <semx element="autonum" source="term-sub-item">02</semx>
                                     </span>
                                  </fmt-xref>
                                  )
                               </semx>
                            </fmt-concept>
                            ,
                            <concept id="_">
                               <refterm>191-01-02</refterm>
                               <renderterm>191-01-02</renderterm>
                               <termref base="IEV" target="191-01-02"/>
                            </concept>
                            <fmt-concept>
                               <semx element="concept" source="_">
                                  <em>191-01-02</em>
                                  (
                                  <termref base="IEV" target="191-01-02"/>
                                  )
                               </semx>
                            </fmt-concept>
                            )
                         </p>
                      </termnote>
                   </term>
                   <term id="term-sub-item">
                      <fmt-name>
                         <span class="fmt-caption-label">
                            <semx element="autonum" source="_">192-01</semx>
                            <span class="fmt-autonum-delim">-</span>
                            <semx element="autonum" source="term-sub-item">02</semx>
                         </span>
                      </fmt-name>
                      <fmt-xref-label>
                         <semx element="autonum" source="_">192-01</semx>
                         <span class="fmt-autonum-delim">-</span>
                         <semx element="autonum" source="term-sub-item">02</semx>
                      </fmt-xref-label>
                      <preferred id="_">
                         <expression>
                            <name>sub item</name>
                         </expression>
                      </preferred>
                      <fmt-preferred>
                         <p>
                            <semx element="preferred" source="_">
                               <strong>sub item</strong>
                            </semx>
                         </p>
                      </fmt-preferred>
                      <definition id="_">
                         <verbal-definition>
                            <p original-id="_">part of the subject being considered</p>
                         </verbal-definition>
                      </definition>
                      <fmt-definition>
                         <semx element="definition" source="_">
                            <p id="_">part of the subject being considered</p>
                         </semx>
                      </fmt-definition>
                   </term>
                </terms>
             </clause>
          </sections>
       </iso-standard>
    PRESXML
    expect(Xml::C14n.format(strip_guid(IsoDoc::Iec::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
      .sub(%r{<localized-strings>.*</localized-strings>}m, ""))))
      .to be_equivalent_to Xml::C14n.format(presxml)
  end

  it "processes multilingual IEV terms" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
           <bibdata type='standard'>
                 <docidentifier type='ISO'>IEC 60050-192 ED 1</docidentifier>
                 <docnumber>60050</docnumber>
          </bibdata>
          <sections>
          <clause id="_terms_and_definitions" obligation="normative"><title>Terms and definitions</title>
          <terms id="_general" obligation="normative"><title>General</title>
      <term id="item" language="en" tag="item">
      <preferred><expression language="en"><name>system</name></expression><field-of-application>in dependability</field-of-application></preferred>
      <preferred><expression language="de"><name>Betrachtungseinheit</name<grammar><gender>feminine</gender></grammar></expression></preferred>
      <preferred><expression language="ja"><name>アイテム</name></expression></preferred>
      <preferred><expression language="de"><name>Einheit</name><grammar><gender>feminine</gender></grammar></expression></preferred>
      <preferred><expression language="zh"><name>&#20135;&#21697;</name></expression><field-of-application>在可靠性方面</field-of-application></preferred>
      <preferred><expression language="ar"><name>نظام،</name></expression><field-of-application>في الاعتمادیة</field-of-application></preferred>
      <admitted><expression><name>paddy rice</name></expression></admitted>
      <admitted><expression><name>rough rice</name></expression></admitted>
      <deprecates><expression><name>cargo rice</name></expression></deprecates>
      <related type='contrast'><preferred><expression><name>Fifth Designation</name></expression></preferred><xref target="paddy1"/></related>
      <definition><verbal-definition><p id="_eb29b35e-123e-4d1c-b50b-2714d41e747f">set of interrelated items that collectively fulfil a requirement</p></verbal-definition></definition>
      <termnote id="_671a1994-4783-40d0-bc81-987d06ffb74e">
        <p id="_19830f33-e46c-42cc-94ca-a5ef101132d5">A system is considered to have a defined real or abstract boundary.</p>
      </termnote>
      <termnote id="_671a1994-4783-40d0-bc81-987d06ffb74d">
        <p id="_19830f33-e46c-42cc-94ca-a5ef101132d5">External resources (from outside the system boundary) may be required for the system to operate.</p>
      </termnote>
      <termexample id="_671a1994-4783-40d0-bc81-987d06ffb740">
        <p id="_19830f33-e46c-42cc-94ca-a5ef101132d0">External resources (from outside the system boundary) may be required for the system to operate.</p>
      </termexample>
      <termsource status="modified">
        <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011"><locality type="clause"><referenceFrom>3.1</referenceFrom></locality>ISO 7301:2011, 3.1</origin>
        <modification>modified by extension to suit the dependability context</modification>
      </termsource></term>
      <term id="item-fr" language="fr" tag="item">
      <preferred><expression language="fr"><name>entité</name<grammar><gender>masculine</gender></grammar></expression>
      <field-of-application>en sûreté de fonctionnement</field-of-application>
      </preferred>
      <related type='contrast'><preferred><expression><name>Designation cinquième</name></expression></preferred><xref target="paddy1"/></related>
      <related type='see'><preferred><expression><name>Designation sixième</name></expression></preferred><xref target="paddy1"/></related>
      <definition><verbal-definition><p id="_eb29b35e-123e-4d1c-b50b-2714d41e747d">ensemble d’entités reliées entre elles qui satisfont collectivement à une exigence</p></verbal-definition></definition>
      <termnote id="_671a1994-4783-40d0-bc81-987d06ffb74c">
        <p id="_19830f33-e46c-42cc-94ca-a5ef101132d5">Un système est considéré comme ayant une frontière définie, réelle ou abstraite.</p>
      </termnote>
      <termnote id="_671a1994-4783-40d0-bc81-987d06ffb74b">
        <p id="_19830f33-e46c-42cc-94ca-a5ef101132d5">Des ressources externes (provenant d’au-delà de la frontière) peuvent être nécessaires au fonctionnement du système.</p>
      </termnote>
      <termexample id="_671a1994-4783-40d0-bc81-987d06ffb741">
        <p id="_19830f33-e46c-42cc-94ca-a5ef101132d1">External resources (from outside the system boundary) may be required for the system to operate.</p>
      </termexample>
      <termsource status="modified">
        <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011"><locality type="clause"><referenceFrom>3.1</referenceFrom></locality>ISO 7301:2011, 3.1</origin>
        <modification>modifié pour adapter au contexte de la sûreté de fonctionnement</modification>
      </termsource></term>
      <term id="paddy1"><preferred><expression><name>paddy</name></expression></preferred>
      <definition><verbal-definition><p id="_eb29b35e-123e-4d1c-b50b-2714d41e747d">rice retaining its husk after threshing</p></verbal-definition></definition>
      </term>
      </terms>
      </clause>
      </sections>
      </iso-standard>
    INPUT

    presxml = <<~PRESXML
          <iso-standard xmlns='http://riboseinc.com/isoxml' type='presentation'>
        <bibdata type='standard'>
          <docidentifier type='ISO'>IEC 60050-192 ED 1</docidentifier>
          <docnumber>60050</docnumber>
        </bibdata>
        #{PREFACE}</preface>
          <sections>
              <clause id="_" obligation="normative" displayorder="8">
                 <title id="_">Terms and definitions</title>
                 <fmt-title depth="1">
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
                 <terms id="_" obligation="normative">
                    <title id="_">General</title>
                    <fmt-title>
                       <span class="fmt-caption-label">
                          <semx element="autonum" source="_">192-01</semx>
                       </span>
                       <span class="fmt-caption-delim"> </span>
                       <semx element="title" source="_">General</semx>
                    </fmt-title>
                    <fmt-xref-label>
                       <span class="fmt-element-name">Section</span>
                       <semx element="autonum" source="_">192-01</semx>
                    </fmt-xref-label>
                    <term id="item" language="en,fr">
                       <fmt-name>
                          <span class="fmt-caption-label">
                             <semx element="autonum" source="_">192-01</semx>
                             <span class="fmt-autonum-delim">-</span>
                             <semx element="autonum" source="item">01</semx>
                          </span>
                       </fmt-name>
                       <fmt-xref-label>
                          <semx element="autonum" source="_">192-01</semx>
                          <span class="fmt-autonum-delim">-</span>
                          <semx element="autonum" source="item">01</semx>
                       </fmt-xref-label>
                       <preferred id="_">
                          <expression language="en">
                             <name>system</name>
                          </expression>
                          <field-of-application id="_">in dependability</field-of-application>
                       </preferred>
                       <preferred id="_">
                          <expression language="de">
                             <name>Betrachtungseinheit</name>
                             <grammar>
                                <gender>feminine</gender>
                             </grammar>
                          </expression>
                       </preferred>
                       <preferred id="_">
                          <expression language="ja">
                             <name>アイテム</name>
                          </expression>
                       </preferred>
                       <preferred id="_">
                          <expression language="de">
                             <name>Einheit</name>
                             <grammar>
                                <gender>feminine</gender>
                             </grammar>
                          </expression>
                       </preferred>
                       <preferred id="_">
                          <expression language="zh">
                             <name>产品</name>
                          </expression>
                          <field-of-application original-id="_" id="_">在可靠性方面</field-of-application>
                       </preferred>
                       <preferred id="_">
                          <expression language="ar">
                             <name>نظام،</name>
                          </expression>
                          <field-of-application original-id="_" id="_">في الاعتمادیة</field-of-application>
                       </preferred>
                       <fmt-preferred>
                          <p>
                             <semx element="preferred" source="_">
                                <strong>system</strong>
                                <span class="fmt-designation-field">
                                   , &lt;
                                   <semx element="field-of-application" source="_">in dependability</semx>
                                   &gt;
                                </span>
                                , en
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
                       <related type="contrast" id="_">
                          <preferred>
                             <expression>
                                <name>Fifth Designation</name>
                             </expression>
                          </preferred>
                          <xref target="paddy1"/>
                       </related>
                       <definition id="_">
                          <verbal-definition>
                             <p original-id="_">set of interrelated items that collectively fulfil a requirement</p>
                          </verbal-definition>
                       </definition>
                       <fmt-definition>
                          <semx element="definition" source="_">
                             <p id="_">set of interrelated items that collectively fulfil a requirement</p>
                          </semx>
                          <semx element="related" source="_">
                             <p>
                                CONTRAST:
                                <semx element="preferred" source="_">
                                   <strong>Fifth Designation</strong>
                                </semx>
                                (
                                <xref target="paddy1" id="_"/>
                                <semx element="xref" source="_">
                                   <fmt-xref target="paddy1">
                                      <span class="citesec">
                                         <semx element="autonum" source="_">192-01</semx>
                                         <span class="fmt-autonum-delim">-</span>
                                         <semx element="autonum" source="paddy1">02</semx>
                                      </span>
                                   </fmt-xref>
                                </semx>
                                )
                             </p>
                          </semx>
                       </fmt-definition>
                       <termexample id="_" autonum="">
                          <fmt-name>
                             <span class="fmt-caption-label">
                                <span class="fmt-element-name">EXAMPLE</span>
                             </span>
                          </fmt-name>
                          <fmt-xref-label>
                             <span class="fmt-element-name">Example</span>
                          </fmt-xref-label>
                          <fmt-xref-label container="item">
                             <span class="fmt-xref-container">
                                <semx element="autonum" source="_">192-01</semx>
                                <span class="fmt-autonum-delim">-</span>
                                <semx element="autonum" source="item">01</semx>
                             </span>
                             <span class="fmt-comma">,</span>
                             <span class="fmt-element-name">Example</span>
                          </fmt-xref-label>
                          <p id="_">External resources (from outside the system boundary) may be required for the system to operate.</p>
                       </termexample>
                       <termnote id="_" autonum="1">
                          <fmt-name>
                             <span class="fmt-caption-label">Note 1 to entry</span>
                             <span class="fmt-label-delim">: </span>
                          </fmt-name>
                          <fmt-xref-label>
                             <span class="fmt-element-name">Note</span>
                             <semx element="autonum" source="_">1</semx>
                          </fmt-xref-label>
                          <fmt-xref-label container="item">
                             <span class="fmt-xref-container">
                                <semx element="autonum" source="_">192-01</semx>
                                <span class="fmt-autonum-delim">-</span>
                                <semx element="autonum" source="item">01</semx>
                             </span>
                             <span class="fmt-comma">,</span>
                             <span class="fmt-element-name">Note</span>
                             <semx element="autonum" source="_">1</semx>
                          </fmt-xref-label>
                          <p id="_">A system is considered to have a defined real or abstract boundary.</p>
                       </termnote>
                       <termnote id="_" autonum="2">
                          <fmt-name>
                             <span class="fmt-caption-label">Note 2 to entry</span>
                             <span class="fmt-label-delim">: </span>
                          </fmt-name>
                          <fmt-xref-label>
                             <span class="fmt-element-name">Note</span>
                             <semx element="autonum" source="_">2</semx>
                          </fmt-xref-label>
                          <fmt-xref-label container="item">
                             <span class="fmt-xref-container">
                                <semx element="autonum" source="_">192-01</semx>
                                <span class="fmt-autonum-delim">-</span>
                                <semx element="autonum" source="item">01</semx>
                             </span>
                             <span class="fmt-comma">,</span>
                             <span class="fmt-element-name">Note</span>
                             <semx element="autonum" source="_">2</semx>
                          </fmt-xref-label>
                          <p id="_">External resources (from outside the system boundary) may be required for the system to operate.</p>
                       </termnote>
                       <termsource status="modified" id="_">
                          <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011">
                             <locality type="clause">
                                <referenceFrom>3.1</referenceFrom>
                             </locality>
                             ISO 7301:2011, 3.1
                          </origin>
                          <modification>modified by extension to suit the dependability context</modification>
                       </termsource>
                       <fmt-termsource status="modified">
                          SOURCE:
                          <semx element="termsource" source="_">
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
                             <semx element="modification" source="_">modified by extension to suit the dependability context</semx>
                          </semx>
                       </fmt-termsource>
                       <semx element="term" source="item-fr">
                          <preferred id="_">
                             <expression language="fr">
                                <name>entité</name>
                                <grammar>
                                   <gender>masculine</gender>
                                </grammar>
                             </expression>
                             <field-of-application id="_">en sûreté de fonctionnement</field-of-application>
                          </preferred>
                          <fmt-preferred>
                             <p>
                                <semx element="preferred" source="_">
                                   <strong>entité</strong>
                                   <span class="fmt-designation-field">
                                      , &lt;
                                      <semx element="field-of-application" source="_">en sûreté de fonctionnement</semx>
                                      &gt;
                                   </span>
                                   , m, fr
                                </semx>
                             </p>
                          </fmt-preferred>
                          <related type="contrast" id="_">
                             <preferred>
                                <expression>
                                   <name>Designation cinquième</name>
                                </expression>
                             </preferred>
                             <xref target="paddy1"/>
                          </related>
                          <related type="see" id="_">
                             <preferred>
                                <expression>
                                   <name>Designation sixième</name>
                                </expression>
                             </preferred>
                             <xref target="paddy1"/>
                          </related>
                          <definition id="_">
                             <verbal-definition>
                                <p original-id="_">ensemble d’entités reliées entre elles qui satisfont collectivement à une exigence</p>
                             </verbal-definition>
                          </definition>
                          <fmt-definition>
                             <semx element="definition" source="_">
                                <p id="_">ensemble d’entités reliées entre elles qui satisfont collectivement à une exigence</p>
                             </semx>
                             <semx element="related" source="_">
                                <p>
                                   CONTRASTEZ:
                                   <semx element="preferred" source="_">
                                      <strong>Designation cinquième</strong>
                                   </semx>
                                   (
                                   <xref target="paddy1" id="_"/>
                                   <semx element="xref" source="_">
                                      <fmt-xref target="paddy1">
                                         <span class="citesec">
                                            <semx element="autonum" source="_">192-01</semx>
                                            <span class="fmt-autonum-delim">-</span>
                                            <semx element="autonum" source="paddy1">02</semx>
                                         </span>
                                      </fmt-xref>
                                   </semx>
                                   )
                                </p>
                             </semx>
                             <semx element="related" source="_">
                                <p>
                                   VOIR:
                                   <semx element="preferred" source="_">
                                      <strong>Designation sixième</strong>
                                   </semx>
                                   (
                                   <xref target="paddy1" id="_"/>
                                   <semx element="xref" source="_">
                                      <fmt-xref target="paddy1">
                                         <span class="citesec">
                                            <semx element="autonum" source="_">192-01</semx>
                                            <span class="fmt-autonum-delim">-</span>
                                            <semx element="autonum" source="paddy1">02</semx>
                                         </span>
                                      </fmt-xref>
                                   </semx>
                                   )
                                </p>
                             </semx>
                          </fmt-definition>
                          <termexample id="_" autonum="">
                             <fmt-name>
                                <span class="fmt-caption-label">
                                   <span class="fmt-element-name">EXEMPLE</span>
                                </span>
                             </fmt-name>
                             <fmt-xref-label>
                                <span class="fmt-element-name">Example</span>
                             </fmt-xref-label>
                             <fmt-xref-label container="item-fr">
                                <span class="fmt-xref-container">
                                   <semx element="autonum" source="_">192-01</semx>
                                   <span class="fmt-autonum-delim">-</span>
                                   <semx element="autonum" source="item-fr">02</semx>
                                </span>
                                <span class="fmt-comma">,</span>
                                <span class="fmt-element-name">Example</span>
                             </fmt-xref-label>
                             <p id="_">External resources (from outside the system boundary) may be required for the system to operate.</p>
                          </termexample>
                          <termnote id="_" autonum="1">
                             <fmt-name>
                                <span class="fmt-caption-label">Note 1 à l’article</span>
                                <span class="fmt-label-delim">: </span>
                             </fmt-name>
                             <fmt-xref-label>
                                <span class="fmt-element-name">Note</span>
                                <semx element="autonum" source="_">1</semx>
                             </fmt-xref-label>
                             <fmt-xref-label container="item-fr">
                                <span class="fmt-xref-container">
                                   <semx element="autonum" source="_">192-01</semx>
                                   <span class="fmt-autonum-delim">-</span>
                                   <semx element="autonum" source="item-fr">02</semx>
                                </span>
                                <span class="fmt-comma">,</span>
                                <span class="fmt-element-name">Note</span>
                                <semx element="autonum" source="_">1</semx>
                             </fmt-xref-label>
                             <p id="_">Un système est considéré comme ayant une frontière définie, réelle ou abstraite.</p>
                          </termnote>
                          <termnote id="_" autonum="2">
                             <fmt-name>
                                <span class="fmt-caption-label">Note 2 à l’article</span>
                                <span class="fmt-label-delim">: </span>
                             </fmt-name>
                             <fmt-xref-label>
                                <span class="fmt-element-name">Note</span>
                                <semx element="autonum" source="_">2</semx>
                             </fmt-xref-label>
                             <fmt-xref-label container="item-fr">
                                <span class="fmt-xref-container">
                                   <semx element="autonum" source="_">192-01</semx>
                                   <span class="fmt-autonum-delim">-</span>
                                   <semx element="autonum" source="item-fr">02</semx>
                                </span>
                                <span class="fmt-comma">,</span>
                                <span class="fmt-element-name">Note</span>
                                <semx element="autonum" source="_">2</semx>
                             </fmt-xref-label>
                             <p id="_">Des ressources externes (provenant d’au-delà de la frontière) peuvent être nécessaires au fonctionnement du système.</p>
                          </termnote>
                          <termsource status="modified" id="_">
                             <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011">
                                <locality type="clause">
                                   <referenceFrom>3.1</referenceFrom>
                                </locality>
                                ISO 7301:2011, 3.1
                             </origin>
                             <modification>modifié pour adapter au contexte de la sûreté de fonctionnement</modification>
                          </termsource>
                          <fmt-termsource status="modified">
                             SOURCE:
                             <semx element="termsource" source="_">
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
                                , modifié —
                                <semx element="modification" source="_">modifié pour adapter au contexte de la sûreté de fonctionnement</semx>
                             </semx>
                          </fmt-termsource>
                       </semx>
                       <dl type="other-lang">
                          <dt>ar</dt>
                          <dd language="ar" script="Arab">
                             <semx element="preferred" source="_">
                                <strong>؜نظام،؜</strong>
                                <span class="fmt-designation-field">
                                   ؜, &lt;؜
                                   <semx element="field-of-application" source="_">؜في الاعتمادیة؜</semx>
                                   ؜&gt;؜
                                </span>
                             </semx>
                          </dd>
                          <dt>de</dt>
                          <dd language="de" script="Latn">
                             <semx element="preferred" source="_">
                                <strong>Betrachtungseinheit</strong>
                                , f
                             </semx>
                             <semx element="preferred" source="_">
                                <strong>Einheit</strong>
                                , f
                             </semx>
                          </dd>
                          <dt>ja</dt>
                          <dd language="ja" script="Jpan">
                             <semx element="preferred" source="_">
                                <strong>アイテム</strong>
                             </semx>
                          </dd>
                          <dt>zh</dt>
                          <dd language="zh" script="Hans">
                             <semx element="preferred" source="_">
                                <strong>产品</strong>
                                <span class="fmt-designation-field">
                                   ,
                                   <semx element="field-of-application" source="_">在可靠性方面</semx>
                                   &gt;
                                </span>
                             </semx>
                          </dd>
                       </dl>
                    </term>
                    <term id="item-fr" language="fr" tag="item" unnumbered="true">
                       <preferred original-id="_">
                          <expression language="fr">
                             <name>entité</name>
                             <grammar>
                                <gender>masculine</gender>
                             </grammar>
                          </expression>
                          <field-of-application original-id="_">en sûreté de fonctionnement</field-of-application>
                       </preferred>
                       <related type="contrast" original-id="_">
                          <preferred>
                             <expression>
                                <name>Designation cinquième</name>
                             </expression>
                          </preferred>
                          <xref target="paddy1"/>
                       </related>
                       <related type="see" original-id="_">
                          <preferred>
                             <expression>
                                <name>Designation sixième</name>
                             </expression>
                          </preferred>
                          <xref target="paddy1"/>
                       </related>
                       <definition original-id="_">
                          <verbal-definition>
                             <p original-id="_">ensemble d’entités reliées entre elles qui satisfont collectivement à une exigence</p>
                          </verbal-definition>
                       </definition>
                       <termexample autonum="" original-id="_">
                          <p original-id="_">External resources (from outside the system boundary) may be required for the system to operate.</p>
                       </termexample>
                       <termnote autonum="1" original-id="_">
                          <p original-id="_">Un système est considéré comme ayant une frontière définie, réelle ou abstraite.</p>
                       </termnote>
                       <termnote autonum="2" original-id="_">
                          <p original-id="_">Des ressources externes (provenant d’au-delà de la frontière) peuvent être nécessaires au fonctionnement du système.</p>
                       </termnote>
                       <termsource status="modified" original-id="_">
                          <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011">
                             <locality type="clause">
                                <referenceFrom>3.1</referenceFrom>
                             </locality>
                             ISO 7301:2011, 3.1
                          </origin>
                          <modification>modifié pour adapter au contexte de la sûreté de fonctionnement</modification>
                       </termsource>
                    </term>
                    <term id="paddy1">
                       <fmt-name>
                          <span class="fmt-caption-label">
                             <semx element="autonum" source="_">192-01</semx>
                             <span class="fmt-autonum-delim">-</span>
                             <semx element="autonum" source="paddy1">02</semx>
                          </span>
                       </fmt-name>
                       <fmt-xref-label>
                          <semx element="autonum" source="_">192-01</semx>
                          <span class="fmt-autonum-delim">-</span>
                          <semx element="autonum" source="paddy1">02</semx>
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
                       <definition id="_">
                          <verbal-definition>
                             <p original-id="_">rice retaining its husk after threshing</p>
                          </verbal-definition>
                       </definition>
                       <fmt-definition>
                          <semx element="definition" source="_">
                             <p id="_">rice retaining its husk after threshing</p>
                          </semx>
                       </fmt-definition>
                    </term>
                 </terms>
              </clause>
           </sections>
        </iso-standard>
    PRESXML
       html = <<~OUTPUT
             #{HTML_HDR}
                <div id="_">
                   <h1>1  Terms and definitions</h1>
                   <br/>
                   <div id="_">
                      <h2 class="zzSTDTitle2">
                         <b>192-01 General</b>
                      </h2>
                      <p class="TermNum" id="item">192-01-01</p>
                      <p class="Terms" style="text-align:left;">
                         <b>system</b>
                         , &lt;in dependability&gt;, en
                      </p>
                      <p class="AltTerms" style="text-align:left;">paddy rice</p>
                      <p class="AltTerms" style="text-align:left;">rough rice</p>
                      <p class="DeprecatedTerms" style="text-align:left;">DEPRECATED: cargo rice</p>
                      <p id="_">set of interrelated items that collectively fulfil a requirement</p>
                      <p>
                         CONTRAST:
                         <b>Fifth Designation</b>
                         (
                         <a href="#paddy1">
                            <span class="citesec">192-01-02</span>
                         </a>
                         )
                      </p>
                      <div id="_" class="example">
                         <p>
                            <span class="example_label">EXAMPLE</span>
                              External resources (from outside the system boundary) may be required for the system to operate.
                         </p>
                      </div>
                      <div id="_" class="Note">
                         <p>
                            <span class="termnote_label">Note 1 to entry: </span>
                            A system is considered to have a defined real or abstract boundary.
                         </p>
                      </div>
                      <div id="_" class="Note">
                         <p>
                            <span class="termnote_label">Note 2 to entry: </span>
                            External resources (from outside the system boundary) may be required for the system to operate.
                         </p>
                      </div>
                      <p>SOURCE: ISO 7301:2011, 3.1, modified — modified by extension to suit the dependability context</p>
                      <p class="Terms" style="text-align:left;">
                         <b>entité</b>
                         , &lt;en sûreté de fonctionnement&gt;, m, fr
                      </p>
                      <p id="_">ensemble d’entités reliées entre elles qui satisfont collectivement à une exigence</p>
                      <p>
                         CONTRASTEZ:
                         <b>Designation cinquième</b>
                         (
                         <a href="#paddy1">
                            <span class="citesec">192-01-02</span>
                         </a>
                         )
                      </p>
                      <p>
                         VOIR:
                         <b>Designation sixième</b>
                         (
                         <a href="#paddy1">
                            <span class="citesec">192-01-02</span>
                         </a>
                         )
                      </p>
                      <div id="_" class="example">
                         <p>
                            <span class="example_label">EXEMPLE</span>
                              External resources (from outside the system boundary) may be required for the system to operate.
                         </p>
                      </div>
                      <div id="_" class="Note">
                         <p>
                            <span class="termnote_label">Note 1 à l’article: </span>
                            Un système est considéré comme ayant une frontière définie, réelle ou abstraite.
                         </p>
                      </div>
                      <div id="_" class="Note">
                         <p>
                            <span class="termnote_label">Note 2 à l’article: </span>
                            Des ressources externes (provenant d’au-delà de la frontière) peuvent être nécessaires au fonctionnement du système.
                         </p>
                      </div>
                      <p>SOURCE: ISO 7301:2011, 3.1, modifié — modifié pour adapter au contexte de la sûreté de fonctionnement</p>
                      <div class="figdl">
                         <dl>
                            <dt>
                               <p>ar</p>
                            </dt>
                            <dd>
                               <b>؜نظام،؜</b>
                               ؜, &lt;؜؜في الاعتمادیة؜؜&gt;؜
                            </dd>
                            <dt>
                               <p>de</p>
                            </dt>
                            <dd>
                               <b>Betrachtungseinheit</b>
                               , f
                               <b>Einheit</b>
                               , f
                            </dd>
                            <dt>
                               <p>ja</p>
                            </dt>
                            <dd>
                               <b>アイテム</b>
                            </dd>
                            <dt>
                               <p>zh</p>
                            </dt>
                            <dd>
                               <b>产品</b>
                               , 在可靠性方面&gt;
                            </dd>
                         </dl>
                      </div>
                      <p class="TermNum" id="paddy1">192-01-02</p>
                      <p class="Terms" style="text-align:left;">
                         <b>paddy</b>
                      </p>
                      <p id="_">rice retaining its husk after threshing</p>
                   </div>
                </div>
             </div>
          </body>
       </html>
    OUTPUT
       pres_output = IsoDoc::Iec::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(pres_output
      .sub(%r{<localized-strings>.*</localized-strings>}m, ""))))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(IsoDoc::Iec::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Xml::C14n.format(html)

  end
end
