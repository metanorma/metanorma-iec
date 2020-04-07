require "spec_helper"
  
RSpec.describe IsoDoc do
  it "processes introductions under IEV" do
    expect(xmlpp(IsoDoc::Iec::HtmlConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
       #{HTML_HDR}
      <div>
        <h1 class='ForewordTitle'>FOREWORD</h1>
        <div class='boilerplate_legal'/>
        <p id='A'>This is a preamble</p>
      </div>
      <br/>
      <div class='Section3' id='B'>
        <h1 class='IntroTitle'>
          INTRODUCTION
          <br/>
          Principles and rules followed
        </h1>
        <div id='C'>
          <h2>Introduction Subsection</h2>
        </div>
      </div>
      #{IEC_TITLE}
    </div>
  </body>
</html>
       OUTPUT
  end

  it "processes bibliographies under IEV" do
    expect(xmlpp(IsoDoc::Iec::HtmlConvert.new({}).convert("test", <<~"INPUT", true))).to be_equivalent_to xmlpp(<<~"OUTPUT")
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
           <references id='_' obligation='informative'>
             <title>Normative References</title>
             <p id='_'>There are no normative references in this document.</p>
             <bibitem id='A'>
               <formattedref format='application/x-isodoc+xml'>
                 <em>TITLE</em>
               </formattedref>
               <docidentifier>B</docidentifier>
             </bibitem>
           </references>
           <references id='_' obligation='informative'>
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
 #{HTML_HDR}
 <div id=''>
  <h1 class='ForewordTitle'>FOREWORD</h1>
  <div class='boilerplate_legal'/>
</div>
      #{IEC_TITLE}
      <div>
  <h1>1&#160; Normative references</h1>
  <p id='_'>There are no normative references in this document.</p>
</div>
    </div>
  </body>
</html>
OUTPUT
  end


end

