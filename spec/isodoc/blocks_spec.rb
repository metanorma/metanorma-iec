require "spec_helper"

RSpec.describe IsoDoc::Iec do
  it "processes formulae (Word)" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword displayorder="1"><fmt-title id="_">FOREWORD</fmt-title>
          <formula id="_be9158af-7e93-4ee2-90c5-26d31c181934" unnumbered="true">
        <fmt-stem type="AsciiMath">r = 1 %</fmt-stem>
      <dl id="_e4fe94fe-1cde-49d9-b1ad-743293b7e21d">
        <dt>
          <fmt-stem type="AsciiMath">r</fmt-stem>
        </dt>
        <dd>
          <p id="_1b99995d-ff03-40f5-8f2e-ab9665a69b77">is the repeatability limit.</p>
        </dd>
      </dl>
          <note id="_83083c7a-6c85-43db-a9fa-4d8edd0c9fc0">
          <fmt-name id="_">NOTE<tab/></fmt-name>
        <p id="_511aaa98-4116-42af-8e5b-c87cdf5bfdc8">[durationUnits] is essentially a duration statement without the "P" prefix. "P" is unnecessary because between "G" and "U" duration is always expressed.</p>
      </note>
          </formula>
          <formula id="_be9158af-7e93-4ee2-90c5-26d31c181935"><fmt-name id="_">(1)</fmt-name>
        <fmt-stem type="AsciiMath">r = 1 %</fmt-stem>
        </formula>
          </foreword></preface>
          </iso-standard>
    INPUT
    output = <<~OUTPUT
      <html xmlns:epub='http://www.idpf.org/2007/ops' lang='en'>
               <head>
                 <style>
                 </style>
                 <style>
                 </style>
               </head>
                <body lang="EN-US" link="blue" vlink="#954F72">
                            <div class="WordSection2">
                <div>
                   <h1 class="ForewordTitle">FOREWORD</h1>
                   <div id="_">
                      <div class="formula">
                         <p class="formula">
                            <span style="mso-tab-count:1">  </span>
                            <span class="stem">(#(r = 1 %)#)</span>
                         </p>
                      </div>
               <div align="left">
                  <table id="_" class="dl">
                     <tr>
                        <td valign="top" align="left">
                           <p align="left" style="margin-left:0pt;text-align:left;">
                              <span class="stem">(#(r)#)</span>
                           </p>
                        </td>
                        <td valign="top">
                           <p id="_">is the repeatability limit.</p>
                        </td>
                     </tr>
                  </table>
               </div>
                      <div id="_" class="Note">
                         <p class="Note">
                            <span class="note_label">
                               NOTE
                               <span style="mso-tab-count:1">  </span>
                            </span>
                            [durationUnits] is essentially a duration statement without the "P" prefix. "P" is unnecessary because between "G" and "U" duration is always expressed.
                         </p>
                      </div>
                   </div>
                   <div id="_">
                      <div class="formula">
                         <p class="formula">
                            <span style="mso-tab-count:1">  </span>
                            <span class="stem">(#(r = 1 %)#)</span>
                            <span style="mso-tab-count:1">  </span>
                            (1)
                         </p>
                      </div>
                   </div>
                </div>
                <p> </p>
             </div>
             <p class="section-break">
                <br clear="all" class="section"/>
             </p>
             <div class="WordSection3"/>
           <br clear="all" style="page-break-before:left;mso-break-type:section-break"/>
           <div class="colophon"/>
         </body>
       </html>
    OUTPUT
    expect(Canon.format_xml(strip_guid(IsoDoc::Iec::WordConvert.new({})
      .convert("test", input, true))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "cross-references formulae" do
    input = <<~INPUT
                  <iso-standard xmlns="http://riboseinc.com/isoxml">
                  <preface>
          <foreword>
          <p>
          <xref target="N1"/>
          <xref target="N2"/>
          </p>
          </foreword>
          </preface>
          <sections>
          <clause id="intro"><title>First</title>
          <formula id="N1">
        <stem type="AsciiMath">r = 1 %</stem>
        </formula>
        <clause id="xyz"><title>Preparatory</title>
          <formula id="N2" inequality="true">
        <stem type="AsciiMath">r = 1 %</stem>
        </formula>
          <xref target="N2"/>
      </clause>
      </sections>
          </iso-standard>
    INPUT
    output = <<~OUTPUT
      <iso-standard xmlns='http://riboseinc.com/isoxml' type="presentation">
           #{PREFACE}
             <foreword id="_" displayorder="8">
                <title id="_">FOREWORD</title>
                <fmt-title id="_" depth="1">
                   <semx element="title" source="_">FOREWORD</semx>
                </fmt-title>
                <p>
                   <xref target="N1" id="_"/>
                   <semx element="xref" source="_">
                      <fmt-xref target="N1">
                         <span class="fmt-xref-container">
                            <span class="fmt-element-name">Clause</span>
                            <semx element="autonum" source="intro">1</semx>
                         </span>
                         <span class="fmt-comma">,</span>
                         <span class="fmt-element-name">Equation</span>
                         <span class="fmt-autonum-delim">(</span>
                         <semx element="autonum" source="N1">1</semx>
                         <span class="fmt-autonum-delim">)</span>
                      </fmt-xref>
                   </semx>
                   <xref target="N2" id="_"/>
                   <semx element="xref" source="_">
                      <fmt-xref target="N2">
                         <span class="fmt-xref-container">
                            <semx element="autonum" source="intro">1</semx>
                            <span class="fmt-autonum-delim">.</span>
                            <semx element="autonum" source="xyz">1</semx>
                         </span>
                         <span class="fmt-comma">,</span>
                         <span class="fmt-element-name">Inequality</span>
                         <span class="fmt-autonum-delim">(</span>
                         <semx element="autonum" source="N2">2</semx>
                         <span class="fmt-autonum-delim">)</span>
                      </fmt-xref>
                   </semx>
                </p>
             </foreword>
          </preface>
          <sections>
             <clause id="intro" displayorder="9">
                <title id="_">First</title>
                <fmt-title id="_" depth="1">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="intro">1</semx>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">First</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">Clause</span>
                   <semx element="autonum" source="intro">1</semx>
                </fmt-xref-label>
                <formula id="N1" autonum="1">
                   <fmt-name id="_">
                      <span class="fmt-caption-label">
                         <span class="fmt-autonum-delim">(</span>
                         1
                         <span class="fmt-autonum-delim">)</span>
                      </span>
                   </fmt-name>
                   <fmt-xref-label>
                      <span class="fmt-element-name">Equation</span>
                      <span class="fmt-autonum-delim">(</span>
                      <semx element="autonum" source="N1">1</semx>
                      <span class="fmt-autonum-delim">)</span>
                   </fmt-xref-label>
                   <fmt-xref-label container="intro">
                      <span class="fmt-xref-container">
                         <span class="fmt-element-name">Clause</span>
                         <semx element="autonum" source="intro">1</semx>
                      </span>
                      <span class="fmt-comma">,</span>
                      <span class="fmt-element-name">Equation</span>
                      <span class="fmt-autonum-delim">(</span>
                      <semx element="autonum" source="N1">1</semx>
                      <span class="fmt-autonum-delim">)</span>
                   </fmt-xref-label>
                   <stem type="AsciiMath" id="_">r = 1 %</stem>
                   <fmt-stem type="AsciiMath">
                      <semx element="stem" source="_">r = 1 %</semx>
                   </fmt-stem>
                </formula>
                <clause id="xyz">
                   <title id="_">Preparatory</title>
                   <fmt-title id="_" depth="2">
                      <span class="fmt-caption-label">
                         <semx element="autonum" source="intro">1</semx>
                         <span class="fmt-autonum-delim">.</span>
                         <semx element="autonum" source="xyz">1</semx>
                      </span>
                      <span class="fmt-caption-delim">
                         <tab/>
                      </span>
                      <semx element="title" source="_">Preparatory</semx>
                   </fmt-title>
                   <fmt-xref-label>
                      <semx element="autonum" source="intro">1</semx>
                      <span class="fmt-autonum-delim">.</span>
                      <semx element="autonum" source="xyz">1</semx>
                   </fmt-xref-label>
                   <formula id="N2" inequality="true" autonum="2">
                      <fmt-name id="_">
                         <span class="fmt-caption-label">
                            <span class="fmt-autonum-delim">(</span>
                            2
                            <span class="fmt-autonum-delim">)</span>
                         </span>
                      </fmt-name>
                      <fmt-xref-label>
                         <span class="fmt-element-name">Inequality</span>
                         <span class="fmt-autonum-delim">(</span>
                         <semx element="autonum" source="N2">2</semx>
                         <span class="fmt-autonum-delim">)</span>
                      </fmt-xref-label>
                      <fmt-xref-label container="xyz">
                         <span class="fmt-xref-container">
                            <semx element="autonum" source="intro">1</semx>
                            <span class="fmt-autonum-delim">.</span>
                            <semx element="autonum" source="xyz">1</semx>
                         </span>
                         <span class="fmt-comma">,</span>
                         <span class="fmt-element-name">Inequality</span>
                         <span class="fmt-autonum-delim">(</span>
                         <semx element="autonum" source="N2">2</semx>
                         <span class="fmt-autonum-delim">)</span>
                      </fmt-xref-label>
                      <stem type="AsciiMath" id="_">r = 1 %</stem>
                      <fmt-stem type="AsciiMath">
                         <semx element="stem" source="_">r = 1 %</semx>
                      </fmt-stem>
                   </formula>
                   <xref target="N2" id="_"/>
                   <semx element="xref" source="_">
                      <fmt-xref target="N2">
                         <span class="fmt-element-name">Inequality</span>
                         <span class="fmt-autonum-delim">(</span>
                         <semx element="autonum" source="N2">2</semx>
                         <span class="fmt-autonum-delim">)</span>
                      </fmt-xref>
                   </semx>
                </clause>
             </clause>
          </sections>
       </iso-standard>
    OUTPUT
    expect(Canon.format_xml(strip_guid(IsoDoc::Iec::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>"))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "does not ignore intervening ul in numbering ol" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface><foreword>
      <ul>
      <li>A</li>
      <li>
      <ol id="AA">
      <li>List</li>
      </ol>
      </li>
      </ul>
      </foreword></preface>
      </iso-standard>
    INPUT
    presxml = <<~INPUT
        <iso-standard xmlns='http://riboseinc.com/isoxml' type='presentation'>
      #{PREFACE}
             <foreword id="_" displayorder="8">
                <title id="_">FOREWORD</title>
                <fmt-title depth="1" id="_">
                   <semx element="title" source="_">FOREWORD</semx>
                </fmt-title>
                <ul>
                   <li id="_">
                      <fmt-name id="_">
                         <semx element="autonum" source="_">•</semx>
                      </fmt-name>
                      A
                   </li>
                   <li id="_">
                      <fmt-name id="_">
                         <semx element="autonum" source="_">•</semx>
                      </fmt-name>
                      <ol id="AA" type="arabic">
                         <li id="_">
                            <fmt-name id="_">
                               <semx element="autonum" source="_">1</semx>
                               <span class="fmt-label-delim">)</span>
                            </fmt-name>
                            List
                         </li>
                      </ol>
                   </li>
                </ul>
             </foreword>
          </preface>
       </iso-standard>
    INPUT
    expect(Canon.format_xml(strip_guid(IsoDoc::Iec::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))))
      .to be_equivalent_to Canon.format_xml(presxml)
  end

  it "processes unordered lists" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface>
          <foreword displayorder="2" id="fwd"><fmt-title id="_">Foreword</fmt-title>
          <ul id="_61961034-0fb1-436b-b281-828857a59ddb"  keep-with-next="true" keep-lines-together="true">
          <name>Caption</name>
        <li>
          <p id="_cb370dd3-8463-4ec7-aa1a-96f644e2e9a2">Level 1</p>
        </li>
        <li>
          <p id="_60eb765c-1f6c-418a-8016-29efa06bf4f9">deletion of 4.3.</p>
          <ul id="_61961034-0fb1-436b-b281-828857a59ddc"  keep-with-next="true" keep-lines-together="true">
          <li>
          <p id="_cb370dd3-8463-4ec7-aa1a-96f644e2e9a3">Level 2</p>
          <ul id="_61961034-0fb1-436b-b281-828857a59ddc"  keep-with-next="true" keep-lines-together="true">
          <li>
          <p id="_cb370dd3-8463-4ec7-aa1a-96f644e2e9a3">Level 3</p>
          <ul id="_61961034-0fb1-436b-b281-828857a59ddc"  keep-with-next="true" keep-lines-together="true">
          <li>
          <p id="_cb370dd3-8463-4ec7-aa1a-96f644e2e9a3">Level 4</p>
        </li>
        </ul>
        </li>
        </ul>
        </li>
          </ul>
        </li>
      </ul>
      </foreword></preface>
      </iso-standard>
    INPUT
    presxml = <<~INPUT
           <iso-standard xmlns='http://riboseinc.com/isoxml' type='presentation'>
      #{PREFACE}
             <foreword displayorder="8" id="fwd">
                <title id="_">FOREWORD</title>
                <fmt-title id="_" depth="1">Foreword</fmt-title>
                <ul id="_" keep-with-next="true" keep-lines-together="true">
                   <name id="_">Caption</name>
                   <fmt-name id="_">
                      <semx element="name" source="_">Caption</semx>
                   </fmt-name>
                   <li id="_">
                      <fmt-name id="_">
                         <semx element="autonum" source="_">•</semx>
                      </fmt-name>
                      <p id="_">Level 1</p>
                   </li>
                   <li id="_">
                      <fmt-name id="_">
                         <semx element="autonum" source="_">•</semx>
                      </fmt-name>
                      <p id="_">deletion of 4.3.</p>
                      <ul id="_" keep-with-next="true" keep-lines-together="true">
                         <li id="_">
                            <fmt-name id="_">
                               <semx element="autonum" source="_">—</semx>
                            </fmt-name>
                            <p id="_">Level 2</p>
                            <ul id="_" keep-with-next="true" keep-lines-together="true">
                               <li id="_">
                                  <fmt-name id="_">
                                     <semx element="autonum" source="_">o</semx>
                                  </fmt-name>
                                  <p id="_">Level 3</p>
                                  <ul id="_" keep-with-next="true" keep-lines-together="true">
                                     <li id="_">
                                        <fmt-name id="_">
                                           <semx element="autonum" source="_">•</semx>
                                        </fmt-name>
                                        <p id="_">Level 4</p>
                                     </li>
                                  </ul>
                               </li>
                            </ul>
                         </li>
                      </ul>
                   </li>
                </ul>
             </foreword>
          </preface>
       </iso-standard>
    INPUT
    expect(Canon.format_xml(strip_guid(IsoDoc::Iec::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))))
      .to be_equivalent_to Canon.format_xml(presxml)
  end

  it "processes ordered lists" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface>
          <foreword id="_" displayorder="2">
          <ol id="_ae34a226-aab4-496d-987b-1aa7b6314026" type="alphabet"  keep-with-next="true" keep-lines-together="true">
          <name>Caption</name>
        <li>
          <p id="_0091a277-fb0e-424a-aea8-f0001303fe78">Level 1</p>
          </li>
          </ol>
        <ol id="A">
        <li>
          <p id="_0091a277-fb0e-424a-aea8-f0001303fe78">Level 1</p>
          </li>
        <li>
          <p id="_8a7b6299-db05-4ff8-9de7-ff019b9017b2">Level 1</p>
        <ol>
        <li>
          <p id="_ea248b7f-839f-460f-a173-a58a830b2abe">Level 2</p>
        <ol>
        <li>
          <p id="_ea248b7f-839f-460f-a173-a58a830b2abe">Level 3</p>
        <ol>
        <li>
          <p id="_ea248b7f-839f-460f-a173-a58a830b2abe">Level 4</p>
        </li>
        </ol>
        </li>
        </ol>
        </li>
        </ol>
        </li>
        </ol>
        </li>
      </ol>
      </foreword></preface>
      </iso-standard>
    INPUT
    presxml = <<~INPUT
           <iso-standard xmlns='http://riboseinc.com/isoxml' type='presentation'>
      #{PREFACE}
            <foreword id="_" displayorder="8">
               <title id="_">FOREWORD</title>
               <fmt-title id="_" depth="1">
                  <semx element="title" source="_">FOREWORD</semx>
               </fmt-title>
               <ol id="_" type="alphabet" keep-with-next="true" keep-lines-together="true" autonum="1">
                  <name id="_">Caption</name>
                  <fmt-name id="_">
                     <semx element="name" source="_">Caption</semx>
                  </fmt-name>
                  <li id="_">
                     <fmt-name id="_">
                        <semx element="autonum" source="_">a</semx>
                        <span class="fmt-label-delim">)</span>
                     </fmt-name>
                     <p id="_">Level 1</p>
                  </li>
               </ol>
               <ol id="A" type="alphabet">
                  <li id="_">
                     <fmt-name id="_">
                        <semx element="autonum" source="_">a</semx>
                        <span class="fmt-label-delim">)</span>
                     </fmt-name>
                     <p id="_">Level 1</p>
                  </li>
                  <li id="_">
                     <fmt-name id="_">
                        <semx element="autonum" source="_">b</semx>
                        <span class="fmt-label-delim">)</span>
                     </fmt-name>
                     <p id="_">Level 1</p>
                     <ol type="arabic">
                        <li id="_">
                           <fmt-name id="_">
                              <semx element="autonum" source="_">1</semx>
                              <span class="fmt-label-delim">)</span>
                           </fmt-name>
                           <p id="_">Level 2</p>
                           <ol type="roman">
                              <li id="_">
                                 <fmt-name id="_">
                                    <semx element="autonum" source="_">i</semx>
                                    <span class="fmt-label-delim">)</span>
                                 </fmt-name>
                                 <p id="_">Level 3</p>
                                 <ol type="alphabet_upper">
                                    <li id="_">
                                       <fmt-name id="_">
                                          <semx element="autonum" source="_">A</semx>
                                          <span class="fmt-label-delim">.</span>
                                       </fmt-name>
                                       <p id="_">Level 4</p>
                                    </li>
                                 </ol>
                              </li>
                           </ol>
                        </li>
                     </ol>
                  </li>
               </ol>
            </foreword>
         </preface>
      </iso-standard>
    INPUT
    expect(Canon.format_xml(strip_guid(IsoDoc::Iec::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))))
      .to be_equivalent_to Canon.format_xml(presxml)
  end
end
