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
        <preface>
          <foreword obligation='informative' displayorder="1">
            <title>Foreword</title>
            <p id='A'>This is a preamble</p>
          </foreword>
          <introduction id='B' obligation='informative' displayorder="2">
            <title depth='1'>Introduction</title>
            <clause id='C' inline-header='false' obligation='informative'>
              <title depth='2'>Introduction Subsection</title>
            </clause>
          </introduction>
        </preface>
        <sections/>
      </iso-standard>
    OUTPUT

    html = <<~OUTPUT
             #{HTML_HDR}
            <div>
              <h1 class='ForewordTitle'>FOREWORD</h1>
              <div class='boilerplate_legal'/>
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
    expect(xmlpp(IsoDoc::Iec::PresentationXMLConvert.new({}).convert("test", input, true).sub(%r{<localized-strings>.*</localized-strings>}m, ""))).to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::Iec::HtmlConvert.new({}).convert("test", presxml, true))).to be_equivalent_to xmlpp(html)
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
                  <doctype>article</doctype>
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
                <references id='_' obligation='informative' normative="false">
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
            <substage language="">60</substage>
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
            <doctype language="">article</doctype>
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
          <references obligation='informative' normative='true' id="X" displayorder="1">
          <title depth='1'>1<tab/>Normative References</title>
            <p id='_'>There are no normative references in this document.</p>
            <bibitem id='A'>
              <formattedref format='application/x-isodoc+xml'>
                <em>TITLE</em>
              </formattedref>
              <docidentifier>B</docidentifier>
            </bibitem>
          </references>
          <references id='_' obligation='informative' normative='false' displayorder="2">
            <title depth='1'>Bibliography</title>
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
    OUTPUT
    html = <<~OUTPUT
       #{HTML_HDR}
       <div id=''>
        <h1 class='ForewordTitle'>FOREWORD</h1>
        <div class='boilerplate_legal'/>
      </div>
            #{IEC_TITLE1}
            <div>
        <h1>1&#160; Normative References</h1>
        <p id='_'>There are no normative references in this document.</p>
      </div>
          </div>
        </body>
      </html>
    OUTPUT
    expect(xmlpp(IsoDoc::Iec::PresentationXMLConvert.new({}).convert("test", input, true).sub(%r{<localized-strings>.*</localized-strings>}m, ""))).to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::Iec::HtmlConvert.new({}).convert("test", presxml, true))).to be_equivalent_to xmlpp(html)
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
      <term id="paddy1"><preferred>paddy</preferred>
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
      <term id="paddy"><preferred>paddy</preferred><admitted>paddy rice</admitted>
      <admitted>rough rice</admitted>
      <deprecates>cargo rice</deprecates>
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
          <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
           <bibdata type='standard'>
                 <docidentifier type='ISO'>IEC 60050-192 ED 1</docidentifier>
                 <docnumber>60050</docnumber>
          </bibdata>
          <sections>
          <clause id="_terms_and_definitions" obligation="normative" displayorder="1"><title depth="1">1<tab/>Terms and definitions</title>
          <terms id="_general" obligation="normative"><title>192-01 General</title>
      <term id="paddy1">
      <name>192-01-01</name>
      <preferred>paddy</preferred>
      <definition><p id="_eb29b35e-123e-4d1c-b50b-2714d41e747f">rice retaining its husk after threshing</p></definition>
      <termexample id="_bd57bbf1-f948-4bae-b0ce-73c00431f892">
      <name>EXAMPLE 1</name>
        <p id="_65c9a509-9a89-4b54-a890-274126aeb55c">Foreign seeds, husks, bran, sand, dust.</p>
        <ul>
        <li>A</li>
        </ul>
      </termexample>
      <termexample id="_bd57bbf1-f948-4bae-b0ce-73c00431f894">
      <name>EXAMPLE 2</name>
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
      <name>192-01-02</name>
      <preferred>paddy</preferred><admitted>paddy rice</admitted>
      <admitted>rough rice</admitted>
      <deprecates>cargo rice</deprecates>
      <domain>rice</domain>
      <definition><p id="_eb29b35e-123e-4d1c-b50b-2714d41e747f">rice retaining its husk after threshing</p></definition>
      <termexample id="_bd57bbf1-f948-4bae-b0ce-73c00431f893">
      <name>EXAMPLE</name>
        <ul>
        <li>A</li>
        </ul>
      </termexample>
      <termnote id="_671a1994-4783-40d0-bc81-987d06ffb74e">
      <name>Note 1 to entry</name>
        <p id="_19830f33-e46c-42cc-94ca-a5ef101132d5">The starch of waxy rice consists almost entirely of amylopectin. The kernels have a tendency to stick together after cooking.</p>
      </termnote>
      <termnote id="_671a1994-4783-40d0-bc81-987d06ffb74f">
      <name>Note 2 to entry</name>
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

    html = <<~OUTPUT
       #{HTML_HDR}
            <div id=''>
              <h1 class='ForewordTitle'>FOREWORD</h1>
              <div class='boilerplate_legal'/>
            </div>
                  #{IEC_TITLE1}
            <div id='_terms_and_definitions'>
              <h1>1&#160; Terms and definitions</h1>
              <br/>
              <div id='_general'>
                <p class='zzSTDTitle2'>
                  <b>192-01 General</b>
                </p>
                <p class='TermNum' id='paddy1'>192-01-01</p>
                <p class='Terms' style='text-align:left;'>paddy</p>
                <p id='_eb29b35e-123e-4d1c-b50b-2714d41e747f'>rice retaining its husk after threshing</p>
                <div id='_bd57bbf1-f948-4bae-b0ce-73c00431f892' class='example'>
                  <p>
                    <span class='example_label'>EXAMPLE 1</span>
                    &#160; Foreign seeds, husks, bran, sand, dust.
                  </p>
                  <ul>
                    <li>A</li>
                  </ul>
                </div>
                <div id='_bd57bbf1-f948-4bae-b0ce-73c00431f894' class='example'>
                  <p>
                    <span class='example_label'>EXAMPLE 2</span>
                    &#160;
                  </p>
                  <ul>
                    <li>A</li>
                  </ul>
                </div>
                <p>
                  [TERMREF]
                  <a href='#ISO7301'>ISO 7301:2011, 3.1</a>
                   [MODIFICATION]The term "cargo rice" is shown as deprecated, and
                  Note 1 to entry is not included here [/TERMREF]
                </p>
                <p class='TermNum' id='paddy'>192-01-02</p>
                <p class='Terms' style='text-align:left;'>paddy, &lt;rice&gt;</p>
                <p class='AltTerms' style='text-align:left;'>paddy rice, &lt;rice&gt;</p>
                <p class='AltTerms' style='text-align:left;'>rough rice, &lt;rice&gt;</p>
                <p class='DeprecatedTerms' style='text-align:left;'>DEPRECATED: cargo rice, &lt;rice&gt;</p>
                <p id='_eb29b35e-123e-4d1c-b50b-2714d41e747f'>rice retaining its husk after threshing</p>
                <div id='_bd57bbf1-f948-4bae-b0ce-73c00431f893' class='example'>
                  <p>
                    <span class='example_label'>EXAMPLE</span>
                    &#160;
                  </p>
                  <ul>
                    <li>A</li>
                  </ul>
                </div>
                <div class='Note' id='_671a1994-4783-40d0-bc81-987d06ffb74e'>
                  <p>
                    Note 1 to entry: The starch of waxy rice consists almost entirely
                    of amylopectin. The kernels have a tendency to stick together
                    after cooking.
                  </p>
                </div>
                <div class='Note' id='_671a1994-4783-40d0-bc81-987d06ffb74f'>
                  <p>
                    Note 2 to entry:
                    <ul>
                      <li>A</li>
                    </ul>
                    <p id='_19830f33-e46c-42cc-94ca-a5ef101132d5'>
                      The starch of waxy rice consists almost entirely of amylopectin.
                      The kernels have a tendency to stick together after cooking.
                    </p>
                  </p>
                </div>
                <p>
                  [TERMREF]
                  <a href='#ISO7301'>ISO 7301:2011, 3.1</a>
                   [/TERMREF]
                </p>
              </div>
            </div>
          </div>
        </body>
      </html>
    OUTPUT
    expect(xmlpp(IsoDoc::Iec::PresentationXMLConvert.new({}).convert("test", input, true).sub(%r{<localized-strings>.*</localized-strings>}m, ""))).to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::Iec::HtmlConvert.new({}).convert("test", presxml, true))).to be_equivalent_to xmlpp(html)
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
      <term id="paddy1"><preferred>paddy</preferred>
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
        <sections>
          <clause id='_terms_and_definitions' obligation='normative' displayorder="1">
            <title depth='1'>1<tab/>Terms and definitions</title>
            <terms id='_general' obligation='normative'>
              <title>192-01 General</title>
              <term id='paddy1'>
                <name>192-01-01</name>
                <preferred>paddy</preferred>
                <definition>
                  <p id='_eb29b35e-123e-4d1c-b50b-2714d41e747f'>rice retaining its husk after threshing</p>
                </definition>
                <termsource status='modified'>
                  <origin bibitemid='ISO7301' type='inline' citeas='ISO 7301:2011'>
                    <locality type='clause'>
                      <referenceFrom>3.1</referenceFrom>
                    </locality>
                    ISO 7301:2011, 3.1
                  </origin>
                  <modification>
                    <p id='_e73a417d-ad39-417d-a4c8-20e4e2529489'>
                      The term "cargo rice" is shown as deprecated, and Note 1 to
                      entry is not included here
                    </p>
                  </modification>
                </termsource>
              </term>
            </terms>
          </clause>
        </sections>
      </iso-standard>
    OUTPUT
    expect(xmlpp(IsoDoc::Iec::PresentationXMLConvert.new({}).convert("test", input, true).sub(%r{<localized-strings>.*</localized-strings>}m, ""))).to be_equivalent_to xmlpp(presxml)
    IsoDoc::Iec::WordConvert.new({}).convert("test", presxml, false)
    word = File.read("test.doc").sub(/^.*<div class="WordSection3">/m, '<div class="WordSection3">')
      .sub(%r{<br clear="all" style="page-break-before:left;mso-break-type:section-break"/>.*$}m, "")
    expect(xmlpp(word)).to be_equivalent_to xmlpp(<<~"OUTPUT")
      <div class='WordSection3'>
           <p class='zzSTDTitle1'>
             <b/>
           </p>
           <p class='zzSTDTitle1'>&#xA0;</p>
           <div>
             <a name='_terms_and_definitions' id='_terms_and_definitions'/>
             <h1 class='main'>
               1
               <span style='mso-tab-count:1'>&#xA0; </span>
               Terms and definitions
             </h1>
             <p class='MsoNormal'>
               <br clear='all' style='mso-special-character:line-break;page-break-before:always'/>
             </p>
             <div>
               <a name='_general' id='_general'/>
               <p class='zzSTDTitle2'>
                 <b>192-01 General</b>
               </p>
               <p class='TermNum'>
                 <a name='paddy1' id='paddy1'/>
                 192-01-01
               </p>
               <p class='Terms' style='text-align:left;'>paddy</p>
               <p class='MsoNormal'>
                 <a name='_eb29b35e-123e-4d1c-b50b-2714d41e747f' id='_eb29b35e-123e-4d1c-b50b-2714d41e747f'/>
                 rice retaining its husk after threshing
               </p>
               <p class='MsoNormal'>
                 SOURCE:
                 <a href='#ISO7301'>ISO 7301:2011, 3.1</a>
                 , modified &#x2014; The term "cargo rice" is shown as deprecated, and
                 Note 1 to entry is not included here
               </p>
             </div>
           </div>
         </div>
    OUTPUT
  end
end
