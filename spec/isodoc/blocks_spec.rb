require "spec_helper"

RSpec.describe IsoDoc::Iec do
  it "processes formulae (Word)" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
          <formula id="_be9158af-7e93-4ee2-90c5-26d31c181934" unnumbered="true">
        <stem type="AsciiMath">r = 1 %</stem>
      <dl id="_e4fe94fe-1cde-49d9-b1ad-743293b7e21d">
        <dt>
          <stem type="AsciiMath">r</stem>
        </dt>
        <dd>
          <p id="_1b99995d-ff03-40f5-8f2e-ab9665a69b77">is the repeatability limit.</p>
        </dd>
      </dl>
          <note id="_83083c7a-6c85-43db-a9fa-4d8edd0c9fc0">
          <name>NOTE</name>
        <p id="_511aaa98-4116-42af-8e5b-c87cdf5bfdc8">[durationUnits] is essentially a duration statement without the "P" prefix. "P" is unnecessary because between "G" and "U" duration is always expressed.</p>
      </note>
          </formula>
          <formula id="_be9158af-7e93-4ee2-90c5-26d31c181935"><name>1</name>
        <stem type="AsciiMath">r = 1 %</stem>
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
               <body lang='EN-US' link='blue' vlink='#954F72'>
                 <div class='WordSection2'>
                   <p>
                     <br clear='all' style='mso-special-character:line-break;page-break-before:always'/>
                   </p>
                   #{IEC_TITLE}
                   <div>
                     <h1 class='ForewordTitle'>FOREWORD</h1>
                     <div class='boilerplate_legal'/>
                     <div id='_be9158af-7e93-4ee2-90c5-26d31c181934'><div class='formula'>
                       <p class='formula'>
                         <span style='mso-tab-count:1'>&#160; </span>
                         <span class='stem'>(#(r = 1 %)#)</span>
                       </p>
                     </div>
                     <span class='zzMoveToFollowing'>
        where#{' '}
        <span class='stem'>(#(r)#)</span>
      </span>
      <p id='_1b99995d-ff03-40f5-8f2e-ab9665a69b77'>is the repeatability limit.</p>
                     <div id='_83083c7a-6c85-43db-a9fa-4d8edd0c9fc0' class='Note'>
                       <p class='Note'>
                         <span class='note_label'>NOTE</span>
                         <span style='mso-tab-count:1'>&#160; </span>
                         [durationUnits] is essentially a duration statement without the "P"
                         prefix. "P" is unnecessary because between "G" and "U" duration is
                         always expressed.
                       </p>
                     </div>
                     </div>
                     <div id='_be9158af-7e93-4ee2-90c5-26d31c181935'><div class='formula'>
                       <p class='formula'>
                         <span style='mso-tab-count:1'>&#160; </span>
                         <span class='stem'>(#(r = 1 %)#)</span>
                         <span style='mso-tab-count:1'>&#160; </span>
                         (1)
                       </p>
                     </div>
                     </div>
                   </div>
                   <p>&#160;</p>
                 </div>
                 <p>
                   <br clear='all' class='section'/>
                 </p>
                 <div class='WordSection3'>
                   #{IEC_TITLE1}
                 </div>
                 <br clear='all' style='page-break-before:left;mso-break-type:section-break'/>
                 <div class='colophon'/>
               </body>
             </html>
    OUTPUT
    expect(xmlpp(IsoDoc::Iec::WordConvert.new({})
      .convert("test", input, true)))
      .to be_equivalent_to xmlpp(output)
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
           <preface>
             <foreword displayorder="1">
               <p>
                 <xref target='N1'>Clause 1, Equation (1)</xref>
                 <xref target='N2'>1.1, Inequality (2)</xref>
               </p>
             </foreword>
           </preface>
           <sections>
             <clause id='intro' displayorder="2">
               <title depth='1'>
                 1
                 <tab/>
                 First
               </title>
               <formula id='N1'>
                 <name>1</name>
                 <stem type='AsciiMath'>r = 1 %</stem>
               </formula>
               <clause id='xyz'>
                 <title depth='2'>
                   1.1
                   <tab/>
                   Preparatory
                 </title>
                 <formula id='N2' inequality='true'>
                   <name>2</name>
                   <stem type='AsciiMath'>r = 1 %</stem>
                 </formula>
                 <xref target='N2'>Inequality (2)</xref>
               </clause>
             </clause>
           </sections>
         </iso-standard>
    OUTPUT
    expect(xmlpp(IsoDoc::Iec::PresentationXMLConvert.new({})
      .convert("test", input, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>")))
      .to be_equivalent_to xmlpp(output)
  end
end
