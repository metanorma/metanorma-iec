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
    expect(xmlpp(IsoDoc::Iec::PresentationXMLConvert.new({})
      .convert("test", input, true)
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::Iec::HtmlConvert.new({})
      .convert("test", presxml, true)))
      .to be_equivalent_to xmlpp(html)
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
    expect(xmlpp(IsoDoc::Iec::PresentationXMLConvert.new({})
      .convert("test", input, true)
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::Iec::HtmlConvert.new({})
      .convert("test", presxml, true)))
      .to be_equivalent_to xmlpp(html)
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
          <sections>
          <clause id="_terms_and_definitions" obligation="normative" displayorder="1"><title depth="1">1<tab/>Terms and definitions</title>
          <terms id="_general" obligation="normative"><title>192-01 General</title>
      <term id="paddy1">
      <name>192-01-01</name>
      <preferred><strong>paddy</strong></preferred>
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
      <preferred><strong>paddy</strong></preferred><admitted>paddy rice</admitted>
      <admitted>rough rice</admitted>
      <deprecates>cargo rice</deprecates>
      <definition><p id="_eb29b35e-123e-4d1c-b50b-2714d41e747f">&#x3c;rice&#x3e; rice retaining its husk after threshing</p></definition>
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
                <p class='Terms' style='text-align:left;'><b>paddy</b></p>
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
                <p class='Terms' style='text-align:left;'><b>paddy</b></p>
                <p class='AltTerms' style='text-align:left;'>paddy rice</p>
                <p class='AltTerms' style='text-align:left;'>rough rice</p>
                <p class='DeprecatedTerms' style='text-align:left;'>DEPRECATED: cargo rice</p>
                <p id='_eb29b35e-123e-4d1c-b50b-2714d41e747f'>&lt;rice&gt; rice retaining its husk after threshing</p>
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
    expect(xmlpp(IsoDoc::Iec::PresentationXMLConvert.new({})
      .convert("test", input, true)
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::Iec::HtmlConvert.new({})
      .convert("test", presxml, true)))
      .to be_equivalent_to xmlpp(html)
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
        <sections>
          <clause id='_terms_and_definitions' obligation='normative' displayorder="1">
            <title depth='1'>1<tab/>Terms and definitions</title>
            <terms id='_general' obligation='normative'>
              <title>192-01 General</title>
              <term id='paddy1'>
                <name>192-01-01</name>
                <preferred><strong>paddy</strong></preferred>
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
    expect(xmlpp(IsoDoc::Iec::PresentationXMLConvert.new({})
      .convert("test", input, true)
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to xmlpp(presxml)
    IsoDoc::Iec::WordConvert.new({}).convert("test", presxml, false)
    word = File.read("test.doc")
      .sub(/^.*<div class="WordSection3">/m, '<div class="WordSection3">')
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
               <p class='Terms' style='text-align:left;'><b>paddy</b></p>
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
            <doctype language='fr'>Norme international</doctype>
            <doctype language='en'>International Standard</doctype>
            <horizontal language=''>false</horizontal>
            <structuredidentifier>
              <project-number part='192'>IEC 60050</project-number>
            </structuredidentifier>
            <stagename>International standard</stagename>
          </ext>
        </bibdata>
        <sections>
          <clause id='_terms_and_definitions' obligation='normative' displayorder='1'>
            <title depth='1'>1<tab/>Terms and definitions</title>
            <terms id='_general' obligation='normative'>
              <title>192-01 General</title>
              <term id='term-durability'>
                <name>192-01-01</name>
                <preferred><strong>durability, &#x3c;of an item&#x3e;</strong></preferred>
                <definition>
            <verbaldefinition>
              <p id='_eb29b35e-123e-4d1c-b50b-2714d41e747f'>rice retaining its husk after threshing</p>
            </verbaldefinition>
          </definition>
                <termnote id='_5f49cfad-e57e-5029-78cf-5b7e3e10a3b3'>
                  <name>Note 1 to entry</name>
                  <p id='_8c830e60-8f09-73a2-6393-2a27d9c5b1ce'>Dependability includes availability (<em>192-01-02</em>
                     (<xref target='term-sub-item'>192-01-02</xref>),
                    <em>191-01-02</em>
                     [term defined in
                    <termref base='IEV' target='191-01-02'/>])</p>
                </termnote>
              </term>
              <term id='term-sub-item'>
                <name>192-01-02</name>
                <preferred><strong>sub item</strong></preferred>
                <definition>
                  <p id='_6952e988-8803-159d-a32e-57147fbf3d86'>part of the subject being considered</p>
                </definition>
              </term>
            </terms>
          </clause>
        </sections>
      </iso-standard>
    PRESXML
    expect(xmlpp(IsoDoc::Iec::PresentationXMLConvert.new({})
      .convert("test", input, true)
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to xmlpp(presxml)
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
      <preferred><expression language="en"><name>system</name><field-of-application>in dependability</field-of-application></expression></preferred>
      <preferred><expression language="cs"><name>objekt</name></expression></preferred>
      <preferred><expression language="de"><name>Betrachtungseinheit</name<grammar><gender>feminine</gender></grammar></expression></preferred>
      <preferred><expression language="de"><name>Einheit</name><grammar><gender>feminine</gender></grammar></expression></preferred>
      <preferred><expression language="ja"><name>アイテム</name></expression></preferred>
      <admitted><expression><name>paddy rice</name></expression></admitted>
      <admitted><expression><name>rough rice</name></expression></admitted>
      <deprecates><expression><name>cargo rice</name></expression></deprecates>
      <definition><verbal-definition><p id="_eb29b35e-123e-4d1c-b50b-2714d41e747f">set of interrelated items that collectively fulfil a requirement</p></verbal-definition></definition>
      <termnote id="_671a1994-4783-40d0-bc81-987d06ffb74e">
        <p id="_19830f33-e46c-42cc-94ca-a5ef101132d5">A system is considered to have a defined real or abstract boundary.</p>
      </termnote>
      <termnote id="_671a1994-4783-40d0-bc81-987d06ffb74d">
        <p id="_19830f33-e46c-42cc-94ca-a5ef101132d5">External resources (from outside the system boundary) may be required for the system to operate.</p>
      </termnote>
      <termsource status="modified">
        <origin bibitemid="ISO7301" type="inline" citeas="ISO 7301:2011"><locality type="clause"><referenceFrom>3.1</referenceFrom></locality>ISO 7301:2011, 3.1</origin>
        <modification>modified by extension to suit the dependability context</modification>
      </termsource></term>
      <term id="item-fr" language="fr" tag="item">
      <preferred><expression language="fr"><name>entité</name>
      <field-of-application>en sûreté de fonctionnement</field-of-application>
      <grammar><gender>masculine</gender></grammar></expression></preferred>
      <definition><verbal-definition><p id="_eb29b35e-123e-4d1c-b50b-2714d41e747d">ensemble d’entités reliées entre elles qui satisfont collectivement à une exigence</p></verbal-definition></definition>
      <termnote id="_671a1994-4783-40d0-bc81-987d06ffb74c">
        <p id="_19830f33-e46c-42cc-94ca-a5ef101132d5">Un système est considéré comme ayant une frontière définie, réelle ou abstraite.</p>
      </termnote>
      <termnote id="_671a1994-4783-40d0-bc81-987d06ffb74b">
        <p id="_19830f33-e46c-42cc-94ca-a5ef101132d5">Des ressources externes (provenant d’au-delà de la frontière) peuvent être nécessaires au fonctionnement du système.</p>
      </termnote>
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
      <?xml version='1.0'?>
       <iso-standard xmlns='http://riboseinc.com/isoxml' type='presentation'>
         <bibdata type='standard'>
           <docidentifier type='ISO'>IEC 60050-192 ED 1</docidentifier>
           <docnumber>60050</docnumber>
         </bibdata>
         <sections>
           <clause id='_terms_and_definitions' obligation='normative' displayorder='1'>
             <title depth='1'>
               1
               <tab/>
               Terms and definitions
             </title>
             <terms id='_general' obligation='normative'>
               <title>192-01 General</title>
               <term id='item' language='en,fr'>
                 <name>192-01-01</name>
                 <preferred>
                   <strong>system</strong>
                 </preferred>
                 <admitted>paddy rice</admitted>
                 <admitted>rough rice</admitted>
                 <deprecates>cargo rice</deprecates>
                 <definition>
                   <p id='_eb29b35e-123e-4d1c-b50b-2714d41e747f'>set of interrelated items that collectively fulfil a requirement</p>
                 </definition>
                 <termnote id='_671a1994-4783-40d0-bc81-987d06ffb74e'>
                   <name>Note 1 to entry</name>
                   <p id='_19830f33-e46c-42cc-94ca-a5ef101132d5'>A system is considered to have a defined real or abstract boundary.</p>
                 </termnote>
                 <termnote id='_671a1994-4783-40d0-bc81-987d06ffb74d'>
                   <name>Note 2 to entry</name>
                   <p id='_19830f33-e46c-42cc-94ca-a5ef101132d5'>
                     External resources (from outside the system boundary) may be
                     required for the system to operate.
                   </p>
                 </termnote>
                 <termsource status='modified'>
                   <origin bibitemid='ISO7301' type='inline' citeas='ISO 7301:2011'>
                     <locality type='clause'>
                       <referenceFrom>3.1</referenceFrom>
                     </locality>
                     ISO 7301:2011, 3.1
                   </origin>
                   <modification>modified by extension to suit the dependability context</modification>
                 </termsource>
                 <preferred>
                   <strong>entit&#xE9;</strong>
                   , m
                 </preferred>
                 <definition>
                   <p id='_eb29b35e-123e-4d1c-b50b-2714d41e747d'>
                     ensemble d&#x2019;entit&#xE9;s reli&#xE9;es entre elles qui
                     satisfont collectivement &#xE0; une exigence
                   </p>
                 </definition>
                 <termnote id='_671a1994-4783-40d0-bc81-987d06ffb74c'>
                   <name>Note 1 to entry</name>
                   <p id='_19830f33-e46c-42cc-94ca-a5ef101132d5'>
                     Un syst&#xE8;me est consid&#xE9;r&#xE9; comme ayant une
                     fronti&#xE8;re d&#xE9;finie, r&#xE9;elle ou abstraite.
                   </p>
                 </termnote>
                 <termnote id='_671a1994-4783-40d0-bc81-987d06ffb74b'>
                   <name>Note 2 to entry</name>
                   <p id='_19830f33-e46c-42cc-94ca-a5ef101132d5'>
                     Des ressources externes (provenant d&#x2019;au-del&#xE0; de la
                     fronti&#xE8;re) peuvent &#xEA;tre n&#xE9;cessaires au
                     fonctionnement du syst&#xE8;me.
                   </p>
                 </termnote>
                 <termsource status='modified'>
                   <origin bibitemid='ISO7301' type='inline' citeas='ISO 7301:2011'>
                     <locality type='clause'>
                       <referenceFrom>3.1</referenceFrom>
                     </locality>
                     ISO 7301:2011, 3.1
                   </origin>
                   <modification>modifi&#xE9; pour adapter au contexte de la s&#xFB;ret&#xE9; de fonctionnement</modification>
                 </termsource>
                 <dl type='other-lang'>
                   <dt>cs</dt>
                   <dd>
                     <preferred>
                       <strong>objekt</strong>
                     </preferred>
                   </dd>
                   <dt>de</dt>
                   <dd>
                     <preferred>
                       <strong>Betrachtungseinheit</strong>
                       , f
                     </preferred>
                   </dd>
                   <dt>de</dt>
                   <dd>
                     <preferred>
                       <strong>Einheit</strong>
                       , f
                     </preferred>
                   </dd>
                   <dt>ja</dt>
                   <dd>
                     <preferred>
                       <strong>&#x30A2;&#x30A4;&#x30C6;&#x30E0;</strong>
                     </preferred>
                   </dd>
                 </dl>
               </term>
               <term id='paddy1'>
                 <name>192-01-02</name>
                 <preferred>
                   <strong>paddy</strong>
                 </preferred>
                 <definition>
                   <p id='_eb29b35e-123e-4d1c-b50b-2714d41e747d'>rice retaining its husk after threshing</p>
                 </definition>
               </term>
             </terms>
           </clause>
         </sections>
       </iso-standard>
    PRESXML
    expect(xmlpp(IsoDoc::Iec::PresentationXMLConvert.new({})
      .convert("test", input, true)
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to xmlpp(presxml)
  end
end
