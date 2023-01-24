require "spec_helper"

RSpec.describe IsoDoc do
  it "processes English" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata>
      <docnumber>1</docnumber>
      <language>en</language>
      <ext>
      <doctype>international-standard</doctype>
      <horizontal>true</horizontal>
      <function>emc</function>
      </ext>
      </bibdata>
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
      <bibdata>
      <docnumber>1</docnumber>
      <language current="true">en</language>
      <ext>
      <doctype language="">international-standard</doctype><doctype language="fr">Norme internationale</doctype><doctype language="en">International Standard</doctype>
      <horizontal language=''>true</horizontal><horizontal language="fr">Norme horizontale</horizontal><horizontal language="en">Horizontal Standard</horizontal>
      <function language="">emc</function><function language="fr">Publication fondamentale en CEM</function><function language="en">Basic EMC Publication</function>
      </ext>
      </bibdata>
      <preface>
      <foreword obligation="informative" displayorder="1">
         <title>Foreword</title>
         <p id="A">This is a preamble</p>
       </foreword>
        <introduction id="B" obligation="informative" displayorder="2"><title depth="1">Introduction</title><clause id="C" inline-header="false" obligation="informative">
         <title depth="2">0.1<tab/>Introduction Subsection</title>
       </clause>
       <p>This is patent boilerplate</p>
       </introduction></preface><sections>
       <clause id="D" obligation="normative" type="scope" displayorder="3">
         <title depth="1">1<tab/>Scope</title>
         <p id="E">Text</p>
       </clause>
       <clause id="H" obligation="normative" displayorder="5"><title depth="1">3<tab/>Terms, definitions, symbols and abbreviated terms</title><terms id="I" obligation="normative">
         <title depth="2">3.1<tab/>Normal Terms</title>
         <term id="J"><name>3.1.1</name>
         <preferred>Term2</preferred>
       </term>
       </terms>
       <definitions id="K"><title>3.2</title>
         <dl>
         <dt>Symbol</dt>
         <dd>Definition</dd>
         </dl>
       </definitions>
       </clause>
       <definitions id="L" displayorder="6"><title>4</title>
         <dl>
         <dt>Symbol</dt>
         <dd>Definition</dd>
         </dl>
       </definitions>
       <clause id="M" inline-header="false" obligation="normative" displayorder="7"><title depth="1">5<tab/>Clause 4</title><clause id="N" inline-header="false" obligation="normative">
         <title depth="2">5.1<tab/>Introduction</title>
       </clause>
       <clause id="O" inline-header="false" obligation="normative">
         <title depth="2">5.2<tab/>Clause 4.2</title>
       </clause></clause>
       </sections><annex id="P" inline-header="false" obligation="normative" displayorder="8">
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
       </annex><bibliography><references id="R" obligation="informative" normative="true" displayorder="4">
         <title depth="1">2<tab/>Normative References</title>
       </references><clause id="S" obligation="informative" displayorder="9">
         <title depth="1">Bibliography</title>
         <references id="T" obligation="informative" normative="false">
         <title depth="2">Bibliography Subsection</title>
       </references>
       </clause>
       </bibliography>
       </iso-standard>
    OUTPUT

    html = <<~OUTPUT
       #{HTML_HDR}
            <div>
              <h1 class="ForewordTitle">FOREWORD</h1>
              <div class="boilerplate_legal"/>
              <p id="A">This is a preamble</p>
            </div>
            <br/>
            <div class="Section3" id="B">
              <h1 class="IntroTitle">Introduction</h1>
              <div id="C"><h2>0.1&#160; Introduction Subsection</h2>

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
      <div id="I"><h2>3.1&#160; Normal Terms</h2>

         <p class="TermNum" id="J">3.1.1</p>
         <p class="Terms" style="text-align:left;">Term2</p>

       </div><div id="K"><h2>3.2</h2>
         <dl><dt><p>Symbol</p></dt><dd>Definition</dd></dl>
       </div></div>
            <div id="L" class="Symbols">
              <h1>4</h1>
              <dl>
                <dt>
                  <p>Symbol</p>
                </dt>
                <dd>Definition</dd>
              </dl>
            </div>
            <div id="M">
              <h1>5&#160; Clause 4</h1>
              <div id="N"><h2>5.1&#160; Introduction</h2>

       </div>
              <div id="O"><h2>5.2&#160; Clause 4.2</h2>

       </div>
            </div>
            <br/>
            <div id="P" class="Section3">
              <h1 class="Annex"><b>Annex A</b><br/>(normative)<br/><br/><b>Annex</b></h1>
              <div id="Q"><h2>A.1&#160; Annex A.1</h2>

         <div id="Q1"><h3>A.1.1&#160; Annex A.1a</h3>

         </div>
       </div>
              <div id="Q2"><h2>Appendix 1&#160; An Appendix</h2>

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
    expect(xmlpp(IsoDoc::Iec::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::Iec::HtmlConvert.new({})
      .convert("test", presxml, true)))
      .to be_equivalent_to xmlpp(html)
  end

  it "defaults to English" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata>
      <language>tlh</language>
      </bibdata>
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
    output = <<~OUTPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
      <bibdata>
      <language current="true">tlh</language>
      </bibdata>
      <preface>
      <foreword obligation="informative" displayorder="1">
         <title>Foreword</title>
         <p id="A">This is a preamble</p>
       </foreword>
        <introduction id="B" obligation="informative" displayorder="2"><title depth="1">Introduction</title><clause id="C" inline-header="false" obligation="informative">
         <title depth="2">0.1<tab/>Introduction Subsection</title>
       </clause>
       <p>This is patent boilerplate</p>
       </introduction></preface><sections>
       <clause id="D" obligation="normative" type="scope" displayorder="3">
         <title depth="1">1<tab/>Scope</title>
         <p id="E">Text</p>
       </clause>
       <clause id="H" obligation="normative" displayorder="5"><title depth="1">3<tab/>Terms, definitions, symbols and abbreviated terms</title><terms id="I" obligation="normative">
         <title depth="2">3.1<tab/>Normal Terms</title>
         <term id="J"><name>3.1.1</name>
         <preferred>Term2</preferred>
       </term>
       </terms>
       <definitions id="K"><title>3.2</title>
         <dl>
         <dt>Symbol</dt>
         <dd>Definition</dd>
         </dl>
       </definitions>
       </clause>
       <definitions id="L" displayorder="6"><title>4</title>
         <dl>
         <dt>Symbol</dt>
         <dd>Definition</dd>
         </dl>
       </definitions>
       <clause id="M" inline-header="false" obligation="normative" displayorder="7"><title depth="1">5<tab/>Clause 4</title><clause id="N" inline-header="false" obligation="normative">
         <title depth="2">5.1<tab/>Introduction</title>
       </clause>
       <clause id="O" inline-header="false" obligation="normative">
         <title depth="2">5.2<tab/>Clause 4.2</title>
       </clause></clause>
       </sections><annex id="P" inline-header="false" obligation="normative" displayorder="8">
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
       </annex><bibliography><references id="R" obligation="informative" normative="true" displayorder="4">
         <title depth="1">2<tab/>Normative References</title>
       </references><clause id="S" obligation="informative" displayorder="9">
         <title depth="1">Bibliography</title>
         <references id="T" obligation="informative" normative="false">
         <title depth="2">Bibliography Subsection</title>
       </references>
       </clause>
       </bibliography>
       </iso-standard>
    OUTPUT
    expect(xmlpp(IsoDoc::Iec::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to xmlpp(output)
  end

  it "processes French" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <bibdata>
      <language>fr</language>
      <ext>
      <doctype>international-standard</doctype>
      <horizontal>false</horizontal>
      <function>emc</function>
      </ext>
      </bibdata>
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
      <bibdata>
      <language current="true">fr</language>
      <ext>
      <doctype language="">international-standard</doctype><doctype language="fr">Norme internationale</doctype><doctype language="en">International Standard</doctype>
      <horizontal>false</horizontal>
      <function language="">emc</function><function language="fr">Publication fondamentale en CEM</function><function language="en">Basic EMC Publication</function>
      </ext>
      </bibdata>
      <preface>
      <foreword obligation="informative" displayorder="1">
         <title>Foreword</title>
         <p id="A">This is a preamble</p>
       </foreword>
        <introduction id="B" obligation="informative" displayorder="2"><title depth="1">Introduction</title><clause id="C" inline-header="false" obligation="informative">
         <title depth="2">0.1<tab/>Introduction Subsection</title>
       </clause>
       <p>This is patent boilerplate</p>
       </introduction></preface><sections>
       <clause id="D" obligation="normative" type="scope" displayorder="3">
         <title depth="1">1<tab/>Scope</title>
         <p id="E">Text</p>
       </clause>
       <clause id="H" obligation="normative" displayorder="5"><title depth="1">3<tab/>Terms, definitions, symbols and abbreviated terms</title><terms id="I" obligation="normative">
         <title depth="2">3.1<tab/>Normal Terms</title>
         <term id="J"><name>3.1.1</name>
         <preferred>Term2</preferred>
       </term>
       </terms>
       <definitions id="K"><title>3.2</title>
         <dl>
         <dt>Symbol</dt>
         <dd>Definition</dd>
         </dl>
       </definitions>
       </clause>
       <definitions id="L" displayorder="6"><title>4</title>
         <dl>
         <dt>Symbol</dt>
         <dd>Definition</dd>
         </dl>
       </definitions>
       <clause id="M" inline-header="false" obligation="normative" displayorder="7"><title depth="1">5<tab/>Clause 4</title><clause id="N" inline-header="false" obligation="normative">
         <title depth="2">5.1<tab/>Introduction</title>
       </clause>
       <clause id="O" inline-header="false" obligation="normative">
         <title depth="2">5.2<tab/>Clause 4.2</title>
       </clause></clause>
       </sections><annex id="P" inline-header="false" obligation="normative" displayorder="8">
         <title><strong>Annexe A</strong><br/>(normative)<br/><br/><strong>Annex</strong></title>
         <clause id="Q" inline-header="false" obligation="normative">
         <title depth="2">A.1<tab/>Annex A.1</title>
         <clause id="Q1" inline-header="false" obligation="normative">
         <title depth="3">A.1.1<tab/>Annex A.1a</title>
         </clause>
       </clause>
              <appendix id="Q2" inline-header="false" obligation="normative">
         <title depth="2">Appendice 1<tab/>An Appendix</title>
       </appendix>
       </annex><bibliography><references id="R" obligation="informative" normative="true" displayorder="4">
         <title depth="1">2<tab/>Normative References</title>
       </references><clause id="S" obligation="informative" displayorder="9">
         <title depth="1">Bibliography</title>
         <references id="T" obligation="informative" normative="false">
         <title depth="2">Bibliography Subsection</title>
       </references>
       </clause>
       </bibliography>
       </iso-standard>
    OUTPUT

    html = <<~OUTPUT
      #{HTML_HDR.sub(/INTERNATIONAL ELECTROTECHNICAL COMMISSION/, 'COMMISSION ELECTROTECHNIQUE INTERNATIONALE')
      .gsub(/"en"/, '"fr"')}
               <div>
                 <h1 class="ForewordTitle">AVANT-PROPOS</h1>
                 <div class="boilerplate_legal"/>
                 <p id="A">This is a preamble</p>
               </div>
               <br/>
               <div class="Section3" id="B">
                 <h1 class="IntroTitle">Introduction</h1>
                 <div id="C"><h2>0.1&#160; Introduction Subsection</h2>

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
         <div id="I"><h2>3.1&#160; Normal Terms</h2>

            <p class="TermNum" id="J">3.1.1</p>
            <p class="Terms" style="text-align:left;">Term2</p>

          </div><div id="K"><h2>3.2</h2>
            <dl><dt><p>Symbol</p></dt><dd>Definition</dd></dl>
          </div></div>
               <div id="L" class="Symbols">
                 <h1>4</h1>
                 <dl>
                   <dt>
                     <p>Symbol</p>
                   </dt>
                   <dd>Definition</dd>
                 </dl>
               </div>
               <div id="M">
                 <h1>5&#160; Clause 4</h1>
                 <div id="N"><h2>5.1&#160; Introduction</h2>

          </div>
                 <div id="O"><h2>5.2&#160; Clause 4.2</h2>

          </div>
               </div>
               <br/>
               <div id="P" class="Section3">
                 <h1 class="Annex"><b>Annexe A</b><br/>(normative)<br/><br/><b>Annex</b></h1>
                 <div id="Q"><h2>A.1&#160; Annex A.1</h2>

            <div id="Q1"><h3>A.1.1&#160; Annex A.1a</h3>

            </div>
          </div>
                 <div id="Q2"><h2>Appendice 1&#160; An Appendix</h2>

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
    expect(xmlpp(IsoDoc::Iec::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")))
      .to be_equivalent_to xmlpp(presxml)
    expect(xmlpp(IsoDoc::Iec::HtmlConvert.new({})
      .convert("test", presxml, true)))
      .to be_equivalent_to xmlpp(html)
  end
end
