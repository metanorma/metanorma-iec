require "spec_helper"

RSpec.describe IsoDoc do
  it "processes section names" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface>
      <foreword obligation="informative">
         <title>Foreword</title>
         <p id="A">This is a preamble</p>
       </foreword>
        <introduction id="B" obligation="informative"><title>Introduction</title><clause id="C" inline-header="false" obligation="informative">
         <title>Introduction Subsection</title>
       </clause>
       <p>This is patent boilerplate</p>
       </introduction></preface><sections>
       <clause id="D" obligation="normative" type="scope">
         <title>Scope</title>
         <p id="E">Text</p>
       </clause>

       <clause id="H" obligation="normative"><title>Terms, definitions, symbols and abbreviated terms</title><terms id="I" obligation="normative">
         <title>Normal Terms</title>
         <term id="J">
         <preferred>Term2</preferred>
       </term>
       </terms>
       <definitions id="K">
         <dl>
         <dt>Symbol</dt>
         <dd>Definition</dd>
         </dl>
       </definitions>
       </clause>
       <definitions id="L">
         <dl>
         <dt>Symbol</dt>
         <dd>Definition</dd>
         </dl>
       </definitions>
       <clause id="M" inline-header="false" obligation="normative"><title>Clause 4</title><clause id="N" inline-header="false" obligation="normative">
         <title>Introduction</title>
       </clause>
       <clause id="O" inline-header="false" obligation="normative">
         <title>Clause 4.2</title>
       </clause></clause>

       </sections><annex id="P" inline-header="false" obligation="normative">
         <title>Annex</title>
         <clause id="Q" inline-header="false" obligation="normative">
         <title>Annex A.1</title>
         <clause id="Q1" inline-header="false" obligation="normative">
         <title>Annex A.1a</title>
         </clause>
       </clause>
              <appendix id="Q2" inline-header="false" obligation="normative">
         <title>An Appendix</title>
       </appendix>
       </annex><bibliography><references id="R" obligation="informative" normative="true">
         <title>Normative References</title>
       </references><clause id="S" obligation="informative">
         <title>Bibliography</title>
         <references id="T" obligation="informative" normative="false">
         <title>Bibliography Subsection</title>
       </references>
       </clause>
       </bibliography>
       </iso-standard>
    INPUT

    presxml = <<~OUTPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
      #{PREFACE}
      <foreword obligation="informative" displayorder="8">
         <title>Foreword</title>
         <p id="A">This is a preamble</p>
       </foreword>
        <introduction id="B" obligation="informative" displayorder="9"><title depth="1">Introduction</title><clause id="C" inline-header="false" obligation="informative">
         <title depth="2">0.1<tab/>Introduction Subsection</title>
       </clause>
       <p>This is patent boilerplate</p>
       </introduction></preface><sections>
       <clause id="D" obligation="normative" type="scope" displayorder="10">
         <title depth="1">1<tab/>Scope</title>
         <p id="E">Text</p>
       </clause>

       <clause id="H" obligation="normative" displayorder="12"><title depth="1">3<tab/>Terms, definitions, symbols and abbreviated terms</title><terms id="I" obligation="normative">
         <title depth="2">3.1<tab/>Normal Terms</title>
         <term id="J"><name>3.1.1</name>
         <preferred>Term2</preferred>
       </term>
       </terms>
       <definitions id="K"><title depth="2">
              3.2
              <tab/>
              Symbols
           </title>
         <dl>
         <dt>Symbol</dt>
         <dd>Definition</dd>
         </dl>
       </definitions>
       </clause>
       <definitions id="L" displayorder="13"><title depth="1">
            4
            <tab/>
            Symbols
         </title>
         <dl>
         <dt>Symbol</dt>
         <dd>Definition</dd>
         </dl>
       </definitions>
       <clause id="M" inline-header="false" obligation="normative" displayorder="14"><title depth="1">5<tab/>Clause 4</title><clause id="N" inline-header="false" obligation="normative">
         <title depth="2">5.1<tab/>Introduction</title>
       </clause>
       <clause id="O" inline-header="false" obligation="normative">
         <title depth="2">5.2<tab/>Clause 4.2</title>
       </clause></clause>
        <references id="R" obligation="informative" normative="true" displayorder="11">
         <title depth="1">2<tab/>Normative References</title>
       </references>
       </sections><annex id="P" inline-header="false" obligation="normative" displayorder="15">
         <title><strong>Annex A</strong><br/>(normative)<br/><br/><strong>Annex</strong></title>
         <clause id="Q" inline-header="false" obligation="normative">
         <title depth="2">A.1<tab/>Annex A.1</title>
         <clause id="Q1" inline-header="false" obligation="normative">
         <title depth="3">A.1.1<tab/>Annex A.1a</title>
         </clause>
       </clause>
              <appendix id="Q2" inline-header="false" obligation="normative">
         <title depth="2">Appendix 1<tab/>An Appendix</title>
       </appendix>
       </annex><bibliography>
       <clause id="S" obligation="informative" displayorder="16">
         <title depth="1">Bibliography</title>
         <references id="T" obligation="informative" normative="false">
         <title depth="2">Bibliography Subsection</title>
       </references>
       </clause>
       </bibliography>
       </iso-standard>
    OUTPUT

    html = <<~OUTPUT
      <html xmlns:epub="http://www.idpf.org/2007/ops" lang="en">
           <head/>
           <body lang="en">
             <div class="title-section">
               <p>&#160;</p>
             </div>
             <br/>
             <div class="prefatory-section">
               <p>&#160;</p>
             </div>
             <br/>
             <div class="main-section">
               <br/>
                     <div id="_" class="TOC">
        <h1 class="IntroTitle">Contents</h1>
      </div>
      <br/>
               #{IEC_TITLE}
                  <div>
                    <h1 class="ForewordTitle">Foreword</h1>
                    <p id="A">This is a preamble</p>
                  </div>
                  <br/>
                  <div class="Section3" id="B">
                    <h1 class="IntroTitle">Introduction</h1>
                    <div id="C">
             <h2>0.1&#160; Introduction Subsection</h2>
           </div>
                    <p>This is patent boilerplate</p>
                  </div>
                  #{IEC_TITLE1}
                  <div id="D">
                    <h1>1&#160; Scope</h1>
                    <p id="E">Text</p>
                  </div>
                  <div>
                    <h1>2&#160; Normative References</h1>
                  </div>
                  <div id="H"><h1>3&#160; Terms, definitions, symbols and abbreviated terms</h1>
          <div id="I">
             <h2>3.1&#160; Normal Terms</h2>
             <p class="TermNum" id="J">3.1.1</p>
             <p class="Terms" style="text-align:left;">Term2</p>
           </div><div id="K">
               <h2>
        3.2
         
        Symbols
     </h2>
           <div class="figdl">
             <dl><dt><p>Symbol</p></dt><dd>Definition</dd></dl>
             </div>
           </div></div>
                  <div id="L" class="Symbols">
                    <h1>
      4
       
      Symbols
   </h1>
                    <div class="figdl">
                    <dl>
                      <dt>
                        <p>Symbol</p>
                      </dt>
                      <dd>Definition</dd>
                    </dl>
                    </div>
                  </div>
                  <div id="M">
                    <h1>5&#160; Clause 4</h1>
                    <div id="N">
             <h2>5.1&#160; Introduction</h2>
           </div>
                    <div id="O">
             <h2>5.2&#160; Clause 4.2</h2>
           </div>
                  </div>
                  <br/>
                  <div id="P" class="Section3">
                    <h1 class="Annex"><b>Annex A</b><br/>(normative)<br/><br/><b>Annex</b></h1>
                    <div id="Q">
             <h2>A.1&#160; Annex A.1</h2>
             <div id="Q1">
             <h3>A.1.1&#160; Annex A.1a</h3>
             </div>
           </div>
                    <div id="Q2">
                  <h2>Appendix 1&#160; An Appendix</h2>
                  </div>
                  </div>
                  <br/>
                  <div>
                    <h1 class="Section3">Bibliography</h1>
                    <div>
                      <h2 class="Section3">Bibliography Subsection</h2>
                    </div>
                  </div>
                </div>
              </body>
          </html>
    OUTPUT

    word = <<~OUTPUT
            <body lang="EN-US" link="blue" vlink="#954F72">
              <div class="WordSection2">
                <p class="page-break"><br clear="all" style="mso-special-character:line-break;page-break-before:always"/></p>
                    <div id="_" class="TOC">
        <p class="zzContents">Contents</p>
      </div>
      <p class="page-break">
        <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
      </p>
                #{IEC_TITLE}
                <div>
                  <h1 class="ForewordTitle">Foreword</h1>
                  <p id="A">This is a preamble</p>
                </div>
                <p class="page-break"><br clear="all" style="mso-special-character:line-break;page-break-before:always"/></p>
                <div class="Section3" id="B">
                  <h1 class="IntroTitle">Introduction</h1>
                  <div id="C">
           <h2>0.1<span style="mso-tab-count:1">&#160; </span>Introduction Subsection</h2>
         </div>
                  <p>This is patent boilerplate</p>
                </div>
                <p>&#160;</p>
              </div>
              <p class="section-break"><br clear="all" class="section"/></p>
              <div class="WordSection3">
              #{IEC_TITLE1}
                <div id="D">
                  <h1>1<span style="mso-tab-count:1">&#160; </span>Scope</h1>
                  <p id="E">Text</p>
                </div>
                <div>
                  <h1>2<span style="mso-tab-count:1">&#160; </span>Normative References</h1>
                </div>
                <div id="H"><h1>3<span style="mso-tab-count:1">&#160; </span>Terms, definitions, symbols and abbreviated terms</h1>
        <div id="I">
           <h2>3.1<span style="mso-tab-count:1">&#160; </span>Normal Terms</h2>
           <p class="TermNum" id="J">3.1.1</p>
           <p class="Terms" style="text-align:left;">Term2</p>

         </div><div id="K">
                    <h2>
              3.2
              <span style="mso-tab-count:1">  </span>
              Symbols
           </h2>
           <table class="dl"><tr><td valign="top" align="left"><p align="left" style="margin-left:0pt;text-align:left;">Symbol</p></td><td valign="top">Definition</td></tr></table>
         </div></div>
                <div id="L" class="Symbols">
         <h1>
            4
            <span style="mso-tab-count:1">  </span>
            Symbols
         </h1>
                  <table class="dl">
                    <tr>
                      <td valign="top" align="left">
                        <p align="left" style="margin-left:0pt;text-align:left;">Symbol</p>
                      </td>
                      <td valign="top">Definition</td>
                    </tr>
                  </table>
                </div>
                <div id="M">
                  <h1>5<span style="mso-tab-count:1">&#160; </span>Clause 4</h1>
                  <div id="N">
           <h2>5.1<span style="mso-tab-count:1">&#160; </span>Introduction</h2>
         </div>
                  <div id="O">
           <h2>5.2<span style="mso-tab-count:1">&#160; </span>Clause 4.2</h2>
         </div>
                </div>
                <p class="page-break"><br clear="all" style="mso-special-character:line-break;page-break-before:always"/></p>
                <div id="P" class="Section3">
                  <h1 class="Annex"><b>Annex A</b><br/>(normative)<br/><br/><b>Annex</b></h1>
                  <div id="Q">
           <h2>A.1<span style="mso-tab-count:1">&#160; </span>Annex A.1</h2>
           <div id="Q1">
           <h3>A.1.1<span style="mso-tab-count:1">&#160; </span>Annex A.1a</h3>
           </div>
         </div>
                  <div id="Q2">
           <h2>Appendix 1<span style="mso-tab-count:1">&#160; </span>An Appendix</h2>
         </div>
                </div>
                <p class="page-break"><br clear="all" style="mso-special-character:line-break;page-break-before:always"/></p>
                <div>
                  <h1 class="Section3">Bibliography</h1>
                  <div>
                    <h2 class="Section3">Bibliography Subsection</h2>
                  </div>
                </div>
              </div>
              <br clear="all" style="page-break-before:left;mso-break-type:section-break"/>
              <div class="colophon"/>
            </body>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::Iec::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)))).to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(IsoDoc::Iec::HtmlConvert.new({})
      .convert("test", presxml, true))).to be_equivalent_to Xml::C14n.format(html)
    expect(Xml::C14n.format(IsoDoc::Iec::WordConvert.new({})
      .convert("test", presxml, true)
      .sub(/^.*<body /m, "<body ").sub(%r{</body>.*$}m, "</body>")))
      .to be_equivalent_to Xml::C14n.format(word)
  end

  it "processes subclauses with and without titles" do
    input = <<~INPUT
            <iso-standard xmlns="http://riboseinc.com/isoxml">
             <sections>
             <clause id="D" obligation="normative">
               <title>Scope</title>
      <clause id="D1" obligation="normative">
               <title>Scope 1</title>
               </clause>
      <clause id="D2" obligation="normative">
               </clause>
             </clause>
             </sections>
             </iso-standard>
    INPUT
    output = <<~OUTPUT
      <iso-standard xmlns='http://riboseinc.com/isoxml' type="presentation">
      #{PREFACE}</preface>
        <sections>
          <clause id='D' obligation='normative' displayorder="8">
            <title depth='1'>
              1
              <tab/>
              Scope
            </title>
            <clause id='D1' obligation='normative'>
              <title depth='2'>
                1.1
                <tab/>
                Scope 1
              </title>
            </clause>
            <clause id='D2' obligation='normative'>
              <title>1.2</title>
            </clause>
          </clause>
        </sections>
      </iso-standard>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::Iec::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)))).to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes simple terms & definitions" do
    input = <<~INPUT
              <iso-standard xmlns="http://riboseinc.com/isoxml">
      <sections>
      <terms id="H" obligation="normative" displayorder="1">
        <title>1<tab/>Terms, Definitions, Symbols and Abbreviated Terms</title>
        <term id="J">
        <name>1.1</name>
        <preferred>Term2</preferred>
      </term>
       </terms>
       </sections>
       </iso-standard>
    INPUT
    output = <<~OUTPUT
          #{HTML_HDR_BARE}
      #{IEC_TITLE1}
                     <div id="H"><h1>1&#160; Terms, Definitions, Symbols and Abbreviated Terms</h1>
             <p class="TermNum" id="J">1.1</p>
               <p class="Terms" style="text-align:left;">Term2</p>
             </div>
                   </div>
                 </body>
             </html>
    OUTPUT
    expect(Xml::C14n.format(IsoDoc::Iec::HtmlConvert.new({}).convert("test", input, true)))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "processes inline section headers" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <sections>
       <clause id="M" inline-header="false" obligation="normative" displayorder="1">
        <title>1<tab/>Clause 4</title>
          <clause id="N" inline-header="false" obligation="normative">
         <title>1.1<tab/>Introduction</title>
       </clause>
       <clause id="O" inline-header="true" obligation="normative">
         <title>1.2<tab/>Clause 4.2</title>
       </clause></clause>
       </sections>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      #{HTML_HDR_BARE}
                 #{IEC_TITLE1}
                 <div id="M">
                   <h1>1&#160; Clause 4</h1>
                   <div id="N">
            <h2>1.1&#160; Introduction</h2>
          </div>
                   <div id="O">
            <span class="zzMoveToFollowing inline-header"><b>1.2&#160; Clause 4.2&#160; </b></span>
          </div>
                 </div>
               </div>
             </body>
         </html>
    OUTPUT
    expect(Xml::C14n.format(IsoDoc::Iec::HtmlConvert.new({}).convert("test", input, true)))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "adds colophon to published standard (Word)" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata>
        <status>
          <stage abbreviation="PPUB">60</stage>
          <substage abbreviation="PPUB">60</substage>
        </status>
      </bibdata>
      <sections>
      </sections>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      <body lang="EN-US" link="blue" vlink="#954F72">
        <div class="WordSection2">
          <p> </p>
        </div>
        <p class="section-break">
          <br clear="all" class="section"/>
        </p>
        <div class="WordSection3">
        </div>
        <br clear="all" style="page-break-before:left;mso-break-type:section-break"/>
        <div class="colophon"/>
      </body>
    OUTPUT
    expect(Xml::C14n.format(IsoDoc::Iec::WordConvert.new({}).convert("test", input, true)
      .sub(/^.*<body /m, "<body ").sub(%r{</body>.*$}m, "</body>")))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "does not add colophon to draft standard (Word)" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata>
        <status>
          <stage abbreviation="CD">30</stage>
          <substage abbreviation="CD">00</substage>
        </status>
      </bibdata>
      <sections>
      </sections>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      <body lang="EN-US" link="blue" vlink="#954F72">
           <div class="WordSection2">
             <p> </p>
           </div>
           <p class="section-break">
             <br clear="all" class="section"/>
           </p>
           <div class="WordSection3">
           </div>
         </body>
    OUTPUT
    expect(Xml::C14n.format(IsoDoc::Iec::WordConvert.new({})
      .convert("test", input, true)
      .sub(/^.*<body /m, "<body ")
      .sub(%r{</body>.*$}m, "</body>")))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "adds boilerplate to foreword" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata>
        <ext><doctype>International Standard</doctype></ext>
      </bibdata>
      <boilerplate>
        <legal-statement>
          <p>Boilerplate</p>
        </legal-statement>
      </boilerplate>
      <sections>
      <clause/>
      </sections>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
        <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <bibdata>
            <ext>
              <doctype>International Standard</doctype>
            </ext>
          </bibdata>
          <boilerplate>
            <legal-statement>
              <p>Boilerplate</p>
            </legal-statement>
          </boilerplate>
          #{PREFACE}    <foreword id="_" displayorder="8"><title>FOREWORD</title>
        <clause type="boilerplate_legal">
          <p>Boilerplate</p>
        </clause>
      </foreword>
      </preface>
          <sections>
      <clause displayorder="9"/>
      </sections>
        </iso-standard>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::Iec::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
    .sub(%r{<localized-strings>.*</localized-strings>}m, ""))))
      .to be_equivalent_to Xml::C14n.format(output)

    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata>
        <ext><doctype>International Standard</doctype></ext>
      </bibdata>
      <boilerplate>
        <legal-statement>
          <p>Boilerplate</p>
        </legal-statement>
      </boilerplate>
      <preface><foreword><title>Foreword</title><p>A</p></foreword></preface>
      <sections/>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
        <bibdata>
          <ext>
            <doctype>International Standard</doctype>
          </ext>
        </bibdata>
        <boilerplate>
          <legal-statement>
            <p>Boilerplate</p>
          </legal-statement>
        </boilerplate>
        #{PREFACE}
                <foreword displayorder="8">
          <title>Foreword</title>
                <clause type="boilerplate_legal">
        <p>Boilerplate</p>
      </clause>
          <p>A</p>
        </foreword>
        </preface>
        <sections/>
      </iso-standard>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::Iec::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
    .sub(%r{<localized-strings>.*</localized-strings>}m, ""))))
      .to be_equivalent_to Xml::C14n.format(output)
  end

  it "does not add boilerplate to foreword in amendments" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata>
        <ext><doctype>Amendment</doctype></ext>
      </bibdata>
      <boilerplate>
        <legal-statement>
          <p>Boilerplate</p>
        </legal-statement>
      </boilerplate>
      <sections/>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
        <bibdata>
          <ext>
            <doctype>Amendment</doctype>
          </ext>
        </bibdata>
        <boilerplate>
          <legal-statement>
            <p>Boilerplate</p>
          </legal-statement>
        </boilerplate>
        #{PREFACE}
        </preface>
        <sections/>
      </iso-standard>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::Iec::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
    .sub(%r{<localized-strings>.*</localized-strings>}m, ""))))
      .to be_equivalent_to Xml::C14n.format(output)

    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata>
        <ext><doctype>Amendment</doctype></ext>
      </bibdata>
      <boilerplate>
        <legal-statement>
          <p>Boilerplate</p>
        </legal-statement>
      </boilerplate>
      <preface><foreword><title>Foreword</title></foreword><p>A</p></preface>
      <sections/>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
        <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
          <bibdata>
            <ext>
              <doctype>Amendment</doctype>
            </ext>
          </bibdata>
          <boilerplate>
            <legal-statement>
              <p>Boilerplate</p>
            </legal-statement>
          </boilerplate>
          #{PREFACE}
          <foreword displayorder="8">
        <title>Foreword</title>
      </foreword>
      <p displayorder="9">A</p>
          </preface>
          <sections/>
        </iso-standard>
    OUTPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::Iec::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
    .sub(%r{<localized-strings>.*</localized-strings>}m, ""))))
      .to be_equivalent_to Xml::C14n.format(output)
  end
end
