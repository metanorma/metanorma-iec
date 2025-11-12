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
         <preferred><expression><name>Term2</name></expression></preferred>
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
              <foreword obligation="informative" displayorder="8" id="_">
                 <title id="_">Foreword</title>
                 <fmt-title id="_" depth="1">
                    <semx element="title" source="_">Foreword</semx>
                 </fmt-title>
                 <p id="A">This is a preamble</p>
              </foreword>
              <introduction id="B" obligation="informative" displayorder="9">
                 <title id="_">Introduction</title>
                 <fmt-title id="_" depth="1">
                    <semx element="title" source="_">Introduction</semx>
                 </fmt-title>
                 <clause id="C" inline-header="false" obligation="informative">
                    <title id="_">Introduction Subsection</title>
                    <fmt-title id="_" depth="2">
                       <span class="fmt-caption-label">
                          <semx element="autonum" source="B">0</semx>
                          <span class="fmt-autonum-delim">.</span>
                          <semx element="autonum" source="C">1</semx>
                       </span>
                       <span class="fmt-caption-delim">
                          <tab/>
                       </span>
                       <semx element="title" source="_">Introduction Subsection</semx>
                    </fmt-title>
                    <fmt-xref-label>
                       <semx element="autonum" source="B">0</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="C">1</semx>
                    </fmt-xref-label>
                 </clause>
                 <p>This is patent boilerplate</p>
              </introduction>
           </preface>
           <sections>
              <clause id="D" obligation="normative" type="scope" displayorder="10">
                 <title id="_">Scope</title>
                 <fmt-title id="_" depth="1">
                    <span class="fmt-caption-label">
                       <semx element="autonum" source="D">1</semx>
                    </span>
                    <span class="fmt-caption-delim">
                       <tab/>
                    </span>
                    <semx element="title" source="_">Scope</semx>
                 </fmt-title>
                 <fmt-xref-label>
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="D">1</semx>
                 </fmt-xref-label>
                 <p id="E">Text</p>
              </clause>
              <clause id="H" obligation="normative" displayorder="12">
                 <title id="_">Terms, definitions, symbols and abbreviated terms</title>
                 <fmt-title id="_" depth="1">
                    <span class="fmt-caption-label">
                       <semx element="autonum" source="H">3</semx>
                    </span>
                    <span class="fmt-caption-delim">
                       <tab/>
                    </span>
                    <semx element="title" source="_">Terms, definitions, symbols and abbreviated terms</semx>
                 </fmt-title>
                 <fmt-xref-label>
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="H">3</semx>
                 </fmt-xref-label>
                 <terms id="I" obligation="normative">
                    <title id="_">Normal Terms</title>
                    <fmt-title id="_" depth="2">
                       <span class="fmt-caption-label">
                          <semx element="autonum" source="H">3</semx>
                          <span class="fmt-autonum-delim">.</span>
                          <semx element="autonum" source="I">1</semx>
                       </span>
                       <span class="fmt-caption-delim">
                          <tab/>
                       </span>
                       <semx element="title" source="_">Normal Terms</semx>
                    </fmt-title>
                    <fmt-xref-label>
                       <semx element="autonum" source="H">3</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="I">1</semx>
                    </fmt-xref-label>
                    <term id="J">
                       <fmt-name id="_">
                          <span class="fmt-caption-label">
                             <semx element="autonum" source="H">3</semx>
                             <span class="fmt-autonum-delim">.</span>
                             <semx element="autonum" source="I">1</semx>
                             <span class="fmt-autonum-delim">.</span>
                             <semx element="autonum" source="J">1</semx>
                          </span>
                       </fmt-name>
                       <fmt-xref-label>
                          <semx element="autonum" source="H">3</semx>
                          <span class="fmt-autonum-delim">.</span>
                          <semx element="autonum" source="I">1</semx>
                          <span class="fmt-autonum-delim">.</span>
                          <semx element="autonum" source="J">1</semx>
                       </fmt-xref-label>
                    <preferred id="_">
                  <expression>
                     <name>Term2</name>
                  </expression>
               </preferred>
               <fmt-preferred>
                  <p>
                     <semx element="preferred" source="_"><strong>Term2</strong></semx>
                  </p>
               </fmt-preferred>
                    </term>
                 </terms>
                 <definitions id="K">
                    <title id="_">Symbols</title>
                    <fmt-title id="_" depth="2">
                       <span class="fmt-caption-label">
                          <semx element="autonum" source="H">3</semx>
                          <span class="fmt-autonum-delim">.</span>
                          <semx element="autonum" source="K">2</semx>
                       </span>
                       <span class="fmt-caption-delim">
                          <tab/>
                       </span>
                       <semx element="title" source="_">Symbols</semx>
                    </fmt-title>
                    <fmt-xref-label>
                       <semx element="autonum" source="H">3</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="K">2</semx>
                    </fmt-xref-label>
                    <dl>
                       <dt>Symbol</dt>
                       <dd>Definition</dd>
                    </dl>
                 </definitions>
              </clause>
              <definitions id="L" displayorder="13">
                 <title id="_">Symbols</title>
                 <fmt-title id="_" depth="1">
                    <span class="fmt-caption-label">
                       <semx element="autonum" source="L">4</semx>
                    </span>
                    <span class="fmt-caption-delim">
                       <tab/>
                    </span>
                    <semx element="title" source="_">Symbols</semx>
                 </fmt-title>
                 <fmt-xref-label>
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="L">4</semx>
                 </fmt-xref-label>
                 <dl>
                    <dt>Symbol</dt>
                    <dd>Definition</dd>
                 </dl>
              </definitions>
              <clause id="M" inline-header="false" obligation="normative" displayorder="14">
                 <title id="_">Clause 4</title>
                 <fmt-title id="_" depth="1">
                    <span class="fmt-caption-label">
                       <semx element="autonum" source="M">5</semx>
                    </span>
                    <span class="fmt-caption-delim">
                       <tab/>
                    </span>
                    <semx element="title" source="_">Clause 4</semx>
                 </fmt-title>
                 <fmt-xref-label>
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="M">5</semx>
                 </fmt-xref-label>
                 <clause id="N" inline-header="false" obligation="normative">
                    <title id="_">Introduction</title>
                    <fmt-title id="_" depth="2">
                       <span class="fmt-caption-label">
                          <semx element="autonum" source="M">5</semx>
                          <span class="fmt-autonum-delim">.</span>
                          <semx element="autonum" source="N">1</semx>
                       </span>
                       <span class="fmt-caption-delim">
                          <tab/>
                       </span>
                       <semx element="title" source="_">Introduction</semx>
                    </fmt-title>
                    <fmt-xref-label>
                       <semx element="autonum" source="M">5</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="N">1</semx>
                    </fmt-xref-label>
                 </clause>
                 <clause id="O" inline-header="false" obligation="normative">
                    <title id="_">Clause 4.2</title>
                    <fmt-title id="_" depth="2">
                       <span class="fmt-caption-label">
                          <semx element="autonum" source="M">5</semx>
                          <span class="fmt-autonum-delim">.</span>
                          <semx element="autonum" source="O">2</semx>
                       </span>
                       <span class="fmt-caption-delim">
                          <tab/>
                       </span>
                       <semx element="title" source="_">Clause 4.2</semx>
                    </fmt-title>
                    <fmt-xref-label>
                       <semx element="autonum" source="M">5</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="O">2</semx>
                    </fmt-xref-label>
                 </clause>
              </clause>
              <references id="R" obligation="informative" normative="true" displayorder="11">
                 <title id="_">Normative References</title>
                 <fmt-title id="_" depth="1">
                    <span class="fmt-caption-label">
                       <semx element="autonum" source="R">2</semx>
                    </span>
                    <span class="fmt-caption-delim">
                       <tab/>
                    </span>
                    <semx element="title" source="_">Normative References</semx>
                 </fmt-title>
                 <fmt-xref-label>
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="R">2</semx>
                 </fmt-xref-label>
              </references>
           </sections>
           <annex id="P" inline-header="false" obligation="normative" autonum="A" displayorder="15">
              <title id="_">
                 <strong>Annex</strong>
              </title>
              <fmt-title id="_">
                 <strong>
                    <span class="fmt-caption-label">
                       <span class="fmt-element-name">Annex</span>
                       <semx element="autonum" source="P">A</semx>
                    </span>
                 </strong>
                 <br/>
                 <span class="fmt-obligation">(normative)</span>
                 <span class="fmt-caption-delim">
                    <br/>
                    <br/>
                 </span>
                 <semx element="title" source="_">
                    <strong>Annex</strong>
                 </semx>
              </fmt-title>
              <fmt-xref-label>
                 <span class="fmt-element-name">Annex</span>
                 <semx element="autonum" source="P">A</semx>
              </fmt-xref-label>
              <clause id="Q" inline-header="false" obligation="normative">
                 <title id="_">Annex A.1</title>
                 <fmt-title id="_" depth="2">
                    <span class="fmt-caption-label">
                       <semx element="autonum" source="P">A</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="Q">1</semx>
                    </span>
                    <span class="fmt-caption-delim">
                       <tab/>
                    </span>
                    <semx element="title" source="_">Annex A.1</semx>
                 </fmt-title>
                 <fmt-xref-label>
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="P">A</semx>
                    <span class="fmt-autonum-delim">.</span>
                    <semx element="autonum" source="Q">1</semx>
                 </fmt-xref-label>
                 <clause id="Q1" inline-header="false" obligation="normative">
                    <title id="_">Annex A.1a</title>
                    <fmt-title id="_" depth="3">
                       <span class="fmt-caption-label">
                          <semx element="autonum" source="P">A</semx>
                          <span class="fmt-autonum-delim">.</span>
                          <semx element="autonum" source="Q">1</semx>
                          <span class="fmt-autonum-delim">.</span>
                          <semx element="autonum" source="Q1">1</semx>
                       </span>
                       <span class="fmt-caption-delim">
                          <tab/>
                       </span>
                       <semx element="title" source="_">Annex A.1a</semx>
                    </fmt-title>
                    <fmt-xref-label>
                       <semx element="autonum" source="P">A</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="Q">1</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="Q1">1</semx>
                    </fmt-xref-label>
                 </clause>
              </clause>
              <appendix id="Q2" inline-header="false" obligation="normative" autonum="1">
                 <title id="_">An Appendix</title>
                 <fmt-title id="_" depth="2">
                    <span class="fmt-caption-label">
                       <span class="fmt-element-name">Appendix</span>
                       <semx element="autonum" source="Q2">1</semx>
                    </span>
                    <span class="fmt-caption-delim">
                       <tab/>
                    </span>
                    <semx element="title" source="_">An Appendix</semx>
                 </fmt-title>
                 <fmt-xref-label>
                    <span class="fmt-element-name">Appendix</span>
                    <semx element="autonum" source="Q2">1</semx>
                 </fmt-xref-label>
                 <fmt-xref-label container="P">
                    <span class="fmt-xref-container">
                       <span class="fmt-element-name">Annex</span>
                       <semx element="autonum" source="P">A</semx>
                    </span>
                    <span class="fmt-comma">,</span>
                    <span class="fmt-element-name">Appendix</span>
                    <semx element="autonum" source="Q2">1</semx>
                 </fmt-xref-label>
              </appendix>
           </annex>
           <bibliography>
              <clause id="S" obligation="informative" displayorder="16">
                 <title id="_">Bibliography</title>
                 <fmt-title id="_" depth="1">
                    <semx element="title" source="_">Bibliography</semx>
                 </fmt-title>
                 <references id="T" obligation="informative" normative="false">
                    <title id="_">Bibliography Subsection</title>
                    <fmt-title id="_" depth="2">
                       <semx element="title" source="_">Bibliography Subsection</semx>
                    </fmt-title>
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
                  <div id="_">
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
             <p class="Terms" style="text-align:left;"><b>Term2</b></p>
           </div>
                    <div id="K">
                       <h2>3.2  Symbols</h2>
                       <div class="figdl">
                          <dl>
                             <dt>
                                <p>Symbol</p>
                             </dt>
                             <dd>Definition</dd>
                          </dl>
                       </div>
                    </div>
                 </div>
                 <div id="L" class="Symbols">
                    <h1>4  Symbols</h1>
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
                    <h1>5  Clause 4</h1>
                    <div id="N">
                       <h2>5.1  Introduction</h2>
                    </div>
                    <div id="O">
                       <h2>5.2  Clause 4.2</h2>
                    </div>
                 </div>
                 <br/>
                 <div id="P" class="Section3">
                    <h1 class="Annex">
                       <b>Annex A</b>
                       <br/>
                       <span class="obligation">(normative)</span>
                       <br/>
                       <br/>
                       <b>Annex</b>
                    </h1>
                    <div id="Q">
                       <h2>A.1  Annex A.1</h2>
                       <div id="Q1">
                          <h3>A.1.1  Annex A.1a</h3>
                       </div>
                    </div>
                    <div id="Q2">
                       <h2>Appendix 1  An Appendix</h2>
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
                <div id="_">
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
                <h1>
                   1
                   <span style="mso-tab-count:1">  </span>
                   Scope
                </h1>
                <p id="E">Text</p>
             </div>
             <div>
                <h1>
                   2
                   <span style="mso-tab-count:1">  </span>
                   Normative References
                </h1>
             </div>
             <div id="H">
                <h1>
                   3
                   <span style="mso-tab-count:1">  </span>
                   Terms, definitions, symbols and abbreviated terms
                </h1>
                <div id="I">
                   <h2>
                      3.1
                      <span style="mso-tab-count:1">  </span>
                      Normal Terms
                   </h2>
                   <p class="TermNum" id="J">3.1.1</p>
                   <p class="Terms" style="text-align:left;">
                      <b>Term2</b>
                   </p>
                </div>
                <div id="K">
                   <h2>
                      3.2
                      <span style="mso-tab-count:1">  </span>
                      Symbols
                   </h2>
                   <div align="left">
                      <table class="dl">
                         <tr>
                            <td valign="top" align="left">
                               <p align="left" style="margin-left:0pt;text-align:left;">Symbol</p>
                            </td>
                            <td valign="top">Definition</td>
                         </tr>
                      </table>
                   </div>
                </div>
             </div>
             <div id="L" class="Symbols">
                <h1>
                   4
                   <span style="mso-tab-count:1">  </span>
                   Symbols
                </h1>
                <div align="left">
                   <table class="dl">
                      <tr>
                         <td valign="top" align="left">
                            <p align="left" style="margin-left:0pt;text-align:left;">Symbol</p>
                         </td>
                         <td valign="top">Definition</td>
                      </tr>
                   </table>
                </div>
             </div>
             <div id="M">
                <h1>
                   5
                   <span style="mso-tab-count:1">  </span>
                   Clause 4
                </h1>
                <div id="N">
                   <h2>
                      5.1
                      <span style="mso-tab-count:1">  </span>
                      Introduction
                   </h2>
                </div>
                <div id="O">
                   <h2>
                      5.2
                      <span style="mso-tab-count:1">  </span>
                      Clause 4.2
                   </h2>
                </div>
             </div>
             <p class="page-break">
                <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
             </p>
             <div id="P" class="Section3">
                <h1 class="Annex">
                   <b>Annex A</b>
                   <br/>
                   <span class="obligation">(normative)</span>
                   <br/>
                   <br/>
                   <b>Annex</b>
                </h1>
                <div id="Q">
                   <h2>
                      A.1
                      <span style="mso-tab-count:1">  </span>
                      Annex A.1
                   </h2>
                   <div id="Q1">
                      <h3>
                         A.1.1
                         <span style="mso-tab-count:1">  </span>
                         Annex A.1a
                      </h3>
                   </div>
                </div>
                <div id="Q2">
                   <h2>
                      Appendix 1
                      <span style="mso-tab-count:1">  </span>
                      An Appendix
                   </h2>
                </div>
             </div>
             <p class="page-break">
                <br clear="all" style="mso-special-character:line-break;page-break-before:always"/>
             </p>
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
    pres_output = IsoDoc::Iec::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
    expect(Canon.format_xml(strip_guid(pres_output)))
      .to be_equivalent_to Canon.format_xml(presxml)
    expect(Canon.format_xml(strip_guid(IsoDoc::Iec::HtmlConvert.new({})
      .convert("test", pres_output, true))))
      .to be_equivalent_to Canon.format_xml(html)
    expect(Canon.format_xml(strip_guid(IsoDoc::Iec::WordConvert.new({})
      .convert("test", pres_output, true)
      .sub(/^.*<body /m, "<body ").sub(%r{</body>.*$}m, "</body>"))))
      .to be_equivalent_to Canon.format_xml(word)
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
              <clause id="D" obligation="normative" displayorder="8">
                 <title id="_">Scope</title>
                 <fmt-title id="_" depth="1">
                    <span class="fmt-caption-label">
                       <semx element="autonum" source="D">1</semx>
                    </span>
                    <span class="fmt-caption-delim">
                       <tab/>
                    </span>
                    <semx element="title" source="_">Scope</semx>
                 </fmt-title>
                 <fmt-xref-label>
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="D">1</semx>
                 </fmt-xref-label>
                 <clause id="D1" obligation="normative">
                    <title id="_">Scope 1</title>
                    <fmt-title id="_" depth="2">
                       <span class="fmt-caption-label">
                          <semx element="autonum" source="D">1</semx>
                          <span class="fmt-autonum-delim">.</span>
                          <semx element="autonum" source="D1">1</semx>
                       </span>
                       <span class="fmt-caption-delim">
                          <tab/>
                       </span>
                       <semx element="title" source="_">Scope 1</semx>
                    </fmt-title>
                    <fmt-xref-label>
                       <semx element="autonum" source="D">1</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="D1">1</semx>
                    </fmt-xref-label>
                 </clause>
                 <clause id="D2" obligation="normative">
                    <fmt-title id="_" depth="2">
                       <span class="fmt-caption-label">
                          <semx element="autonum" source="D">1</semx>
                          <span class="fmt-autonum-delim">.</span>
                          <semx element="autonum" source="D2">2</semx>
                       </span>
                    </fmt-title>
                    <fmt-xref-label>
                       <semx element="autonum" source="D">1</semx>
                       <span class="fmt-autonum-delim">.</span>
                       <semx element="autonum" source="D2">2</semx>
                    </fmt-xref-label>
                 </clause>
              </clause>
           </sections>
        </iso-standard>
    OUTPUT
    expect(Canon.format_xml(strip_guid(IsoDoc::Iec::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)))).to be_equivalent_to Canon.format_xml(output)
  end

  it "processes inline section headers" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <sections>
       <clause id="M" inline-header="false" obligation="normative" displayorder="1">
        <fmt-title id="_">1<tab/>Clause 4</fmt-title>
          <clause id="N" inline-header="false" obligation="normative">
         <fmt-title id="_">1.1<tab/>Introduction</fmt-title>
       </clause>
       <clause id="O" inline-header="true" obligation="normative">
         <fmt-title id="_">1.2<tab/>Clause 4.2</fmt-title>
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
    expect(Canon.format_xml(IsoDoc::Iec::HtmlConvert.new({}).convert("test", input, true)))
      .to be_equivalent_to Canon.format_xml(output)
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
    expect(Canon.format_xml(IsoDoc::Iec::WordConvert.new({}).convert("test", input, true)
      .sub(/^.*<body /m, "<body ").sub(%r{</body>.*$}m, "</body>")))
      .to be_equivalent_to Canon.format_xml(output)
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
    expect(Canon.format_xml(IsoDoc::Iec::WordConvert.new({})
      .convert("test", input, true)
      .sub(/^.*<body /m, "<body ")
      .sub(%r{</body>.*$}m, "</body>")))
      .to be_equivalent_to Canon.format_xml(output)
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
          #{PREFACE}
              <foreword id="_" displayorder="8">
                 <title id="_">FOREWORD</title>
                 <fmt-title id="_" depth="1">
                    <semx element="title" source="_">FOREWORD</semx>
                 </fmt-title>
                 <clause type="boilerplate_legal" id="_">
                    <p>Boilerplate</p>
                 </clause>
              </foreword>
           </preface>
           <sections>
              <clause id="_" displayorder="9">
                 <fmt-title id="_" depth="1">
                    <span class="fmt-caption-label">
                       <semx element="autonum" source="_">1</semx>
                    </span>
                 </fmt-title>
                 <fmt-xref-label>
                    <span class="fmt-element-name">Clause</span>
                    <semx element="autonum" source="_">1</semx>
                 </fmt-xref-label>
              </clause>
           </sections>
        </iso-standard>
    OUTPUT
    expect(Canon.format_xml(strip_guid(IsoDoc::Iec::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
    .sub(%r{<localized-strings>.*</localized-strings>}m, ""))))
      .to be_equivalent_to Canon.format_xml(output)

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
                <foreword displayorder="8" id="_">
                         <title id="_">Foreword</title>
         <fmt-title id="_" depth="1">
            <semx element="title" source="_">Foreword</semx>
         </fmt-title>
                <clause type="boilerplate_legal" id="_">
        <p>Boilerplate</p>
      </clause>
          <p>A</p>
        </foreword>
        </preface>
        <sections/>
      </iso-standard>
    OUTPUT
    expect(Canon.format_xml(strip_guid(IsoDoc::Iec::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
    .sub(%r{<localized-strings>.*</localized-strings>}m, ""))))
      .to be_equivalent_to Canon.format_xml(output)
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
    expect(Canon.format_xml(strip_guid(IsoDoc::Iec::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
    .sub(%r{<localized-strings>.*</localized-strings>}m, ""))))
      .to be_equivalent_to Canon.format_xml(output)

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
          <foreword displayorder="8" id="_">
         <title id="_">Foreword</title>
         <fmt-title id="_" depth="1">
            <semx element="title" source="_">Foreword</semx>
         </fmt-title>
      </foreword>
      <p displayorder="9">A</p>
          </preface>
          <sections/>
        </iso-standard>
    OUTPUT
    expect(Canon.format_xml(strip_guid(IsoDoc::Iec::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
    .sub(%r{<localized-strings>.*</localized-strings>}m, ""))))
      .to be_equivalent_to Canon.format_xml(output)
  end
end
