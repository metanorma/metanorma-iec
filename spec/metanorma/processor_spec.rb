require "spec_helper"
require "metanorma"
require "fileutils"

#RSpec.describe Asciidoctor::Gb do
RSpec.describe Metanorma::Iec::Processor do

  registry = Metanorma::Registry.instance
  registry.register(Metanorma::Iec::Processor)
  processor = registry.find_processor(:iec)

  it "registers against metanorma" do
    expect(processor).not_to be nil
  end

  it "registers output formats against metanorma" do
    expect(processor.output_formats.sort.to_s).to be_equivalent_to <<~"OUTPUT"
    [[:doc, "doc"], [:html, "html"], [:pdf, "pdf"], [:presentation, "presentation.xml"], [:rxl, "rxl"], [:xml, "xml"]]
    OUTPUT
  end

  it "registers version against metanorma" do
    expect(processor.version.to_s).to match(%r{^Metanorma::Iec })
  end

  it "generates IsoDoc XML from a blank document" do
    expect(xmlpp(strip_guid(processor.input_to_isodoc(<<~"INPUT", nil)))).to be_equivalent_to xmlpp(<<~"OUTPUT")
    #{ASCIIDOC_BLANK_HDR}
    INPUT
    #{BLANK_HDR}
<sections/>
</iec-standard>
    OUTPUT
  end

  it "generates HTML from IsoDoc XML" do
    FileUtils.rm_f "test.xml"
    processor.output(<<~"INPUT", "test.xml", "test.html", :html)
               <iec-standard xmlns="http://riboseinc.com/isoxml">
       <sections>
       <terms id="H" obligation="normative"><title>Terms, Definitions, Symbols and Abbreviated Terms</title>
         <term id="J">
         <preferred>Term2</preferred>
       </term>
        </terms>
        </sections>
        </iec-standard>
    INPUT
    expect(xmlpp(File.read("test.html", encoding: "utf-8").gsub(%r{^.*<main}m, "<main").gsub(%r{</main>.*}m, "</main>"))).to be_equivalent_to xmlpp(<<~"OUTPUT")
           <main class="main-section"><button onclick="topFunction()" id="myBtn" title="Go to top">Top</button>
              <br />
 <p class="zzSTDTitle1">INTERNATIONAL ELECTROTECHNICAL COMMISSION</p>
 <p class="zzSTDTitle1">____________</p>
 <p class="zzSTDTitle1">&#xA0;</p>
 <p class="zzSTDTitle1">
   <b></b>
 </p>
 <p class="zzSTDTitle1">&#xA0;</p>
 <div id="">
   <h1 class="ForewordTitle" id="toc0">FOREWORD</h1>
   <div class="boilerplate_legal"></div>
 </div>
 <p class="zzSTDTitle1">
   <b></b>
 </p>
 <p class="zzSTDTitle1">&#xA0;</p>
             <div id="H"><h1 id="toc1">1&#xA0; Terms, Definitions, Symbols and Abbreviated Terms</h1>
       <h2 class="TermNum" id="J">1.1</h2>
         <p class="Terms" style="text-align:left;">Term2</p>
       </div>
           </main>
    OUTPUT
  end

end
