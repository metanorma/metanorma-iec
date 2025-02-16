require "spec_helper"
require "fileutils"

RSpec.describe IsoDoc::Iec do
  FileUtils.rm_f "test.html"
  it "processes isodoc as ISO: HTML output" do
    IsoDoc::Iec::HtmlConvert.new({})
      .convert("test", <<~"INPUT", false)
            <iso-standard xmlns="http://riboseinc.com/isoxml">
            <preface><foreword>
            <note>
          <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
        </note>
            </foreword></preface>
            </iso-standard>
      INPUT
    html = File.read("test.html", encoding: "utf-8")
    expect(html).to match(%r[\bpre[^{]+\{[^{]+font-family: "Courier New", monospace;]m)
    expect(html).to match(%r[blockquote[^{]+\{[^{]+font-family: "Arial", sans-serif;]m)
    expect(html).to match(%r[\.h2Annex[^{]+\{[^{]+font-family: "Arial", sans-serif;]m)
  end

  it "processes isodoc as ISO: Chinese HTML output" do
    FileUtils.rm_f "test.html"
    IsoDoc::Iec::HtmlConvert.new({ script: "Hans" })
      .convert("test", <<~"INPUT", false)
            <iso-standard xmlns="http://riboseinc.com/isoxml">
            <preface><foreword>
            <note>
          <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
        </note>
            </foreword></preface>
            </iso-standard>
      INPUT
    html = File.read("test.html", encoding: "utf-8")
    expect(html).to match(%r[\bpre[^{]+\{[^{]+font-family: "Courier New", monospace;]m)
    expect(html).to match(%r[blockquote[^{]+\{[^{]+font-family: "Source Han Sans", serif;]m)
    expect(html).to match(%r[\.h2Annex[^{]+\{[^{]+font-family: "Source Han Sans", sans-serif;]m)
  end

  it "processes isodoc as ISO: user nominated fonts" do
    FileUtils.rm_f "test.html"
    IsoDoc::Iec::HtmlConvert
      .new({ bodyfont: "Zapf Chancery", headerfont: "Comic Sans",
             monospacefont: "Andale Mono" })
      .convert("test", <<~"INPUT", false)
            <iso-standard xmlns="http://riboseinc.com/isoxml">
            <preface><foreword>
            <note>
          <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
        </note>
            </foreword></preface>
            </iso-standard>
      INPUT
    html = File.read("test.html", encoding: "utf-8")
    expect(html).to match(%r[\bpre[^{]+\{[^{]+font-family: Andale Mono;]m)
    expect(html).to match(%r[blockquote[^{]+\{[^{]+font-family: Zapf Chancery;]m)
    expect(html).to match(%r[\.h2Annex[^{]+\{[^{]+font-family: Comic Sans;]m)
  end

  it "processes isodoc as ISO: Word output" do
    FileUtils.rm_f "test.doc"
    IsoDoc::Iec::WordConvert.new({})
      .convert("test", <<~"INPUT", false)
            <iso-standard xmlns="http://riboseinc.com/isoxml">
            <preface><foreword>
            <note>
          <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">These results are based on a study carried out on three different types of kernel.</p>
        </note>
            </foreword></preface>
            </iso-standard>
      INPUT
    html = File.read("test.doc", encoding: "utf-8")
    expect(html).to match(%r[\bpre[^{]+\{[^{]+font-family: "Courier New", monospace;]m)
    expect(html).to match(%r[Quote[^{]+\{[^{]+font-family: "Arial", sans-serif;]m)
    expect(html).to match(%r[\.h2Annex[^{]+\{[^{]+font-family: "Arial", sans-serif;]m)
  end

  it "processes examples" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword displayorder="1"><fmt-title>FOREWORD</fmt-title>
          <example id="samplecode">
          <fmt-name>EXAMPLE</fmt-name>
        <p>Hello</p>
      </example>
          </foreword></preface>
          </iso-standard>
    INPUT
    html = <<~OUTPUT
       #{HTML_HDR_BARE}
            <div>
              <h1 class="ForewordTitle">FOREWORD</h1>
              <div id="samplecode" class="example">
                <p><span class="example_label">EXAMPLE</span>&#160; Hello</p>
              </div>
            </div>
            #{IEC_TITLE1}
          </div>
        </body>
      </html>
    OUTPUT
    doc = <<~OUTPUT
            <body lang="EN-US" link="blue" vlink="#954F72">
        <div class="WordSection2">
          <div id="_">
            <h1 class="ForewordTitle">FOREWORD</h1>
            <div id="samplecode" class="example">
              <p><span class="example_label">EXAMPLE</span><span style="mso-tab-count:1">&#160; </span>Hello</p>
            </div>
          </div>
          <p>&#160;</p>
        </div>
        <p class="section-break">
          <br clear="all" class="section"/>
        </p>
        <div class="WordSection3">
          #{IEC_TITLE1}
        </div>
        <br clear="all" style="page-break-before:left;mso-break-type:section-break"/>
        <div class="colophon"/>
      </body>
    OUTPUT
    expect(Xml::C14n.format(IsoDoc::Iec::HtmlConvert.new({})
      .convert("test", input, true)))
      .to be_equivalent_to Xml::C14n.format(html)
    expect(Xml::C14n.format(strip_guid(IsoDoc::Iec::WordConvert.new({})
      .convert("test", input, true))
      .sub(/^.*<body/m, "<body")
      .sub(%r{</body>.*$}m, "</body>")))
      .to be_equivalent_to Xml::C14n.format(doc)
  end

  it "processes sequences of examples" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword displayorder="1"><fmt-title>FOREWORD</fmt-title>
          <example id="samplecode">
          <fmt-name>EXAMPLE 1</fmt-name>
        <p>Hello</p>
      </example>
          <example id="samplecode2">
          <fmt-name>EXAMPLE 2</fmt-name>
        <p>Hello</p>
      </example>
          </foreword></preface>
          </iso-standard>
    INPUT
    html = <<~OUTPUT
       #{HTML_HDR_BARE}
            <div>
              <h1 class="ForewordTitle">FOREWORD</h1>
              <div id="samplecode" class="example">
                <p><span class="example_label">EXAMPLE  1</span>&#160; Hello</p>
              </div>
              <div id="samplecode2" class="example">
                <p><span class="example_label">EXAMPLE  2</span>&#160; Hello</p>
              </div>
            </div>
            #{IEC_TITLE1}
          </div>
        </body>
      </html>
    OUTPUT

    doc = <<~OUTPUT
        <body lang="EN-US" link="blue" vlink="#954F72">
        <div class="WordSection2">
          <div id="_">
            <h1 class="ForewordTitle">FOREWORD</h1>
            <div id="samplecode" class="example">
              <p><span class="example_label">EXAMPLE  1</span><span style="mso-tab-count:1">&#160; </span>Hello</p>
            </div>
            <div id="samplecode2" class="example">
              <p><span class="example_label">EXAMPLE  2</span><span style="mso-tab-count:1">&#160; </span>Hello</p>
            </div>
          </div>
          <p>&#160;</p>
        </div>
        <p class="section-break">
          <br clear="all" class="section"/>
        </p>
        <div class="WordSection3">
          #{IEC_TITLE1}
        </div>
        <br clear="all" style="page-break-before:left;mso-break-type:section-break"/>
        <div class="colophon"/>
      </body>
    OUTPUT
    expect(Xml::C14n.format(IsoDoc::Iec::HtmlConvert.new({})
      .convert("test", input, true)))
      .to be_equivalent_to Xml::C14n.format(html)
    expect(Xml::C14n.format(strip_guid(IsoDoc::Iec::WordConvert.new({})
      .convert("test", input, true))
      .sub(/^.*<body/m, "<body")
      .sub(%r{</body>.*$}m, "</body>")))
      .to be_equivalent_to Xml::C14n.format(doc)
  end
end
