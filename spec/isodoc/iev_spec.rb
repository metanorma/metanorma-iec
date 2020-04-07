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
end

