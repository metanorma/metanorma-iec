require "spec_helper"

RSpec.describe IsoDoc::Iec do
  it "processes formulae (Word)" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword displayorder="1"><fmt-title>FOREWORD</fmt-title>
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
          <fmt-name>NOTE<tab/></fmt-name>
        <p id="_511aaa98-4116-42af-8e5b-c87cdf5bfdc8">[durationUnits] is essentially a duration statement without the "P" prefix. "P" is unnecessary because between "G" and "U" duration is always expressed.</p>
      </note>
          </formula>
          <formula id="_be9158af-7e93-4ee2-90c5-26d31c181935"><fmt-name>(1)</fmt-name>
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
                <div id="_">
                   <h1 class="ForewordTitle">FOREWORD</h1>
                   <div id="_">
                      <div class="formula">
                         <p class="formula">
                            <span style="mso-tab-count:1">  </span>
                            <span class="stem">(#(r = 1 %)#)</span>
                         </p>
                      </div>
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
    expect(Xml::C14n.format(strip_guid(IsoDoc::Iec::WordConvert.new({})
      .convert("test", input, true))))
      .to be_equivalent_to Xml::C14n.format(output)
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
                <fmt-title depth="1">
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
                <fmt-title depth="1">
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
                   <fmt-name>
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
                   <fmt-title depth="2">
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
                      <fmt-name>
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
    expect(Xml::C14n.format(strip_guid(IsoDoc::Iec::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>"))))
      .to be_equivalent_to Xml::C14n.format(output)
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
             <foreword displayorder="8" id="_">
                <title id="_">FOREWORD</title>
                <fmt-title depth="1">
                   <semx element="title" source="_">FOREWORD</semx>
                </fmt-title>
                <ul>
                   <li>A</li>
                   <li>
                      <ol id="AA" type="arabic">
                         <li id="_" label="1">List</li>
                      </ol>
                   </li>
                </ul>
             </foreword>
          </preface>
       </iso-standard>
    INPUT
    expect(Xml::C14n.format(strip_guid(IsoDoc::Iec::PresentationXMLConvert.new(presxml_options)
      .convert("test", input, true))))
      .to be_equivalent_to Xml::C14n.format(presxml)
  end
end
