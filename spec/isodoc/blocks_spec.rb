require "spec_helper"

RSpec.describe IsoDoc::Iec do

  it "processes admonitions" do
    expect(xmlpp(IsoDoc::Iec::HtmlConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <admonition id="_70234f78-64e5-4dfc-8b6f-f3f037348b6a" type="caution">
  <p id="_e94663cc-2473-4ccc-9a72-983a74d989f2">Only use paddy or parboiled rice for the determination of husked rice yield.</p>
  <p id="_e94663cc-2473-4ccc-9a72-983a74d989f3">Para 2.</p>
</admonition>
    </foreword></preface>
    </iso-standard>
    INPUT
    #{HTML_HDR}
             <div>
               <h1 class='ForewordTitle'>FOREWORD</h1>
               <div class='boilerplate_legal'/>
               <div id='_70234f78-64e5-4dfc-8b6f-f3f037348b6a' class='Admonition'>
                 <p>
                   CAUTION &#8212; Only use paddy or parboiled rice for the
                   determination of husked rice yield.
                 </p>
                 <p id='_e94663cc-2473-4ccc-9a72-983a74d989f3'>Para 2.</p>
               </div>
             </div>
             #{IEC_TITLE}
           </div>
         </body>
       </html>
    OUTPUT
  end

  it "processes admonitions with titles" do
    expect(xmlpp(IsoDoc::Iec::HtmlConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    <iso-standard xmlns="http://riboseinc.com/isoxml">
    <preface><foreword>
    <admonition id="_70234f78-64e5-4dfc-8b6f-f3f037348b6a" type="caution">
    <name>Title</name>
    <ul>
    <li>List</li>
    </ul>
  <p id="_e94663cc-2473-4ccc-9a72-983a74d989f2">Only use paddy or parboiled rice for the determination of husked rice yield.</p>
</admonition>
    </foreword></preface>
    </iso-standard>
    INPUT
     #{HTML_HDR}
             <div>
               <h1 class='ForewordTitle'>FOREWORD</h1>
               <div class='boilerplate_legal'/>
               <div id='_70234f78-64e5-4dfc-8b6f-f3f037348b6a' class='Admonition'>
                 <p>Title &#8212; </p>
                 <ul>
                   <li>List</li>
                 </ul>
                 <p id='_e94663cc-2473-4ccc-9a72-983a74d989f2'>Only use paddy or parboiled rice for the determination of husked rice yield.</p>
               </div>
             </div>
             #{IEC_TITLE}
           </div>
         </body>
       </html>
    OUTPUT
  end

  it "processes formulae (Word)" do
    expect(xmlpp(IsoDoc::Iec::WordConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
  <p id="_511aaa98-4116-42af-8e5b-c87cdf5bfdc8">[durationUnits] is essentially a duration statement without the "P" prefix. "P" is unnecessary because between "G" and "U" duration is always expressed.</p>
</note>
    </formula>
    <formula id="_be9158af-7e93-4ee2-90c5-26d31c181935">
  <stem type="AsciiMath">r = 1 %</stem>
  </formula>
    </foreword></preface>
    </iso-standard>
    INPUT
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
               <div id='_be9158af-7e93-4ee2-90c5-26d31c181934' class='formula'>
                 <p class='formula'>
                   <span style='mso-tab-count:1'>&#160; </span>
                   <span class='stem'>(#(r = 1 %)#)</span>
                 </p>
               </div>
               <p>where</p>
               <table class='formula_dl'>
                 <tr>
                   <td valign='top' align='left'>
                     <p align='left' style='margin-left:0pt;text-align:left;'>
                       <span class='stem'>(#(r)#)</span>
                     </p>
                   </td>
                   <td valign='top'>
                     <p id='_1b99995d-ff03-40f5-8f2e-ab9665a69b77'>is the repeatability limit.</p>
                   </td>
                 </tr>
               </table>
               <div id='_83083c7a-6c85-43db-a9fa-4d8edd0c9fc0' class='Note'>
                 <p class='Note'>
                   <span class='note_label'>NOTE</span>
                   <span style='mso-tab-count:1'>&#160; </span>
                   [durationUnits] is essentially a duration statement without the "P"
                   prefix. "P" is unnecessary because between "G" and "U" duration is
                   always expressed.
                 </p>
               </div>
               <div id='_be9158af-7e93-4ee2-90c5-26d31c181935' class='formula'>
                 <p class='formula'>
                   <span style='mso-tab-count:1'>&#160; </span>
                   <span class='stem'>(#(r = 1 %)#)</span>
                   <span style='mso-tab-count:1'>&#160; </span>
                   (1)
                 </p>
               </div>
             </div>
             <p>&#160;</p>
           </div>
           <p>
             <br clear='all' class='section'/>
           </p>
           <div class='WordSection3'>
             #{IEC_TITLE}
           </div>
           <br clear='all' style='page-break-before:left;mso-break-type:section-break'/>
           <div class='colophon'/>
         </body>
       </html>
    OUTPUT
  end

end
