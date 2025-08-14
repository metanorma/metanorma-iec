require "simplecov"
SimpleCov.start do
  add_filter "/spec/"
end

require "bundler/setup"
require "asciidoctor"
require "metanorma-iec"
require "rspec/matchers"
require "equivalent-xml"
require "metanorma"
require "metanorma/iec"
require "iev"
require "canon"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

def metadata(xml)
  xml.sort.to_h.delete_if do |_k, v|
    v.nil? || (v.respond_to?(:empty?) && v.empty?)
  end
end

def strip_guid(xml)
  xml.gsub(%r{ id="_[^"]+"}, ' id="_"')
    .gsub(%r{ id="(fn:|ftn)_[^"]+"}, ' id="_"')
    .gsub(%r{ semx-id="[^"]*"}, '')
    .gsub(%r{ original-id="_[^"]+"}, ' original-id="_"')
    .gsub(%r{ source="_[^"]+"}, ' source="_"')
    .gsub(%r{ target="_[^"]+"}, ' target="_"')
    .gsub(%r{ name="_[^"]+"}, ' name="_"')
    .gsub(%r( href="#(fn:|ftn)?_?[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12,13}"), ' href="#_"')
    .gsub(%r{<fetched>[^<]+</fetched>}, "<fetched/>")
    .gsub(%r{ schema-version="[^"]+"}, "")
    .gsub(%r( bibitemid="_[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"), ' bibitemid="_"')
end

OPTIONS = [backend: :iec, header_footer: true, agree_to_terms: true].freeze

def presxml_options
  { semanticxmlinsert: "false" }
end

ASCIIDOC_BLANK_HDR = <<~HDR.freeze
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :novalid:
  :no-isobib:

HDR

ISOBIB_BLANK_HDR = <<~HDR.freeze
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :novalid:
  :no-isobib-cache:

HDR

FLUSH_CACHE_ISOBIB_BLANK_HDR = <<~HDR.freeze
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :novalid:
  :flush-caches:

HDR

CACHED_ISOBIB_BLANK_HDR = <<~HDR.freeze
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :novalid:

HDR

LOCAL_CACHED_ISOBIB_BLANK_HDR = <<~HDR.freeze
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :novalid:
  :local-cache:

HDR

VALIDATING_BLANK_HDR = <<~HDR.freeze
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :no-isobib:

HDR

TERMS_BOILERPLATE = <<~BOILERPLATE.freeze
         <p id="_">ISO and IEC maintain terminological databases for use in
         standardization at the following addresses:</p>
          <ul id="_">
          <li> <p id="_">IEC Electropedia: available at
          <link target="http://www.electropedia.org"/>
          </p> </li>
                  <li> <p id="_">ISO Online browsing platform: available at
            <link target="http://www.iso.org/obp"/></p> </li>
  </ul>
BOILERPLATE

def boilerplate_read(file, xmldoc)
  conv = Metanorma::Iec::Converter.new(:iec, {})
  conv.init(Asciidoctor::Document.new([]))
  x = conv.boilerplate_isodoc(xmldoc).populate_template(file, nil)
  ret = conv.boilerplate_file_restructure(x)
  ret.to_xml(encoding: "UTF-8", indent: 2,
             save_with: Nokogiri::XML::Node::SaveOptions::AS_XML)
    .gsub(/<(\/)?sections>/, "<\\1boilerplate>")
    .gsub(/ id="_[^"]+"/, " id='_'")
end

def boilerplate(xmldoc, lang: "en")
  file = File.join(File.dirname(__FILE__), "..", "lib", "metanorma", "iec",
                   "boilerplate-#{lang}.adoc")
  ret = Nokogiri::XML(boilerplate_read(
                        File.read(file, encoding: "utf-8"), xmldoc))
  ret.xpath("//passthrough").each(&:remove)
  strip_guid(ret.root.to_xml(encoding: "UTF-8", indent: 2,
                             save_with: Nokogiri::XML::Node::SaveOptions::AS_XML))
end

BLANK_HDR = <<~"HDR".freeze
  <?xml version="1.0" encoding="UTF-8"?>
  <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" version="#{Metanorma::Iec::VERSION}" flavor="iec">
  <bibdata type="standard">
    <contributor>
      <role type="author"/>
      <organization>
        <name>International Electrotechnical Commission</name>
        <abbreviation>IEC</abbreviation>
      </organization>
    </contributor>
                <contributor>
              <role type="authorizer"><description>Agency</description></role>
              <organization>
                <name>International Electrotechnical Commission</name>
                <abbreviation>IEC</abbreviation>
              </organization>
            </contributor>
               <contributor>
      <role type="publisher"/>
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
      <from>#{Time.new.year}</from>
      <owner>
        <organization>
          <name>International Electrotechnical Commission</name>
          <abbreviation>IEC</abbreviation>
        </organization>
      </owner>
    </copyright>
    <ext>
      <doctype>standard</doctype>
      <flavor>iec</flavor>
    <stagename abbreviation="IS">International Standard</stagename>
    </ext>
  </bibdata>
  <metanorma-extension>
        <semantic-metadata>
         <stage-published>true</stage-published>
      </semantic-metadata>
            <presentation-metadata>
              <name>TOC Heading Levels</name>
              <value>2</value>
            </presentation-metadata>
            <presentation-metadata>
              <name>HTML TOC Heading Levels</name>
              <value>2</value>
            </presentation-metadata>
            <presentation-metadata>
              <name>DOC TOC Heading Levels</name>
              <value>3</value>
            </presentation-metadata>
            <presentation-metadata>
              <name>PDF TOC Heading Levels</name>
              <value>3</value>
            </presentation-metadata>
          </metanorma-extension>
HDR

def blank_hdr_gen
  <<~"HDR"
    #{BLANK_HDR}
    #{boilerplate(Nokogiri::XML("#{BLANK_HDR}</metanorma>"))}
  HDR
end

PREFACE = <<~HDR.freeze
           <preface>
              <clause type="toc" id="_" displayorder="1">
                 <fmt-title depth="1" id="_">Contents</fmt-title>
              </clause>
              <pagebreak displayorder="2"/>
              <p class="zzSTDTitle1" displayorder="3">INTERNATIONAL ELECTROTECHNICAL COMMISSION</p>
              <p class="zzSTDTitle1" displayorder="4">____________</p>
              <p class="zzSTDTitle1" displayorder="5"> </p>
              <p class="zzSTDTitle1" displayorder="6">
                 <strong/>
              </p>
              <p class="zzSTDTitle1" displayorder="7"> </p>
HDR

IEC_TITLE = <<~TITLE.freeze
  <p class="zzSTDTitle1">INTERNATIONAL ELECTROTECHNICAL COMMISSION</p>
              <p class="zzSTDTitle1">____________</p>
              <p class="zzSTDTitle1">&#160;</p>
              <p class="zzSTDTitle1">
                <b/>
              </p>
              <p class="zzSTDTitle1">&#160;</p>
TITLE

IEC_TITLE1 = "".freeze

HTML_HDR = <<~HDR.freeze
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
HDR

HTML_HDR_BARE = <<~HDR.freeze
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
HDR

WORD_HDR = <<~HDR.freeze
  <html xmlns:epub="http://www.idpf.org/2007/ops">
     <head>
       <title>test</title>
     </head>
    <body lang="EN-US" link="blue" vlink="#954F72">
      <div class="WordSection1">
        <p>&#160;</p>
      </div>
      <p><br clear="all" class="section"/></p>
      <div class="WordSection2">
        <p>&#160;</p>
      </div>
      <p><br clear="all" class="section"/></p>
      <div class="WordSection3">
HDR

def stub_fetch_ref(**opts)
  xml = ""

  hit = double("hit")
  expect(hit).to receive(:[]).with("title") do
    Nokogiri::XML(xml).at("//docidentifier").content
  end.at_least(:once)

  hit_instance = double("hit_instance")
  expect(hit_instance).to receive(:hit).and_return(hit).at_least(:once)
  expect(hit_instance).to receive(:to_xml) do |builder, opt|
    expect(builder).to be_instance_of Nokogiri::XML::Builder
    expect(opt).to eq opts
    builder << xml
  end.at_least :once

  hit_page = double("hit_page")
  expect(hit_page).to receive(:first).and_return(hit_instance).at_least :once

  hit_pages = double("hit_pages")
  expect(hit_pages).to receive(:first).and_return(hit_page).at_least :once

  expect(Isobib::IsoBibliography).to receive(:search)
    .and_wrap_original do |search, *args|
    code = args[0]
    expect(code).to be_instance_of String
    xml = get_xml(search, code, opts)
    hit_pages
  end.at_least :once
end

def mock_pdf
  allow(Mn2pdf).to receive(:convert) do |url, output, _c, _d|
    FileUtils.cp(url.gsub('"', ""), output.gsub('"', ""))
  end
end

private

def get_xml(search, code, opts)
  c = code.gsub(%r{[/\s:-]}, "_").sub(%r{_+$}, "").downcase
  o = opts.keys.join "_"
  file = "spec/examples/#{[c, o].join '_'}.xml"
  if File.exist? file
    File.read file
  else
    result = search.call(code)
    hit = result&.first&.first
    xml = hit.to_xml nil, opts
    File.write file, xml
    xml
  end
end

def mock_open_uri(code)
  # expect(OpenURI).to receive(:open_uri).and_wrap_original do |m, *args|
  expect(Iev).to receive(:get).with(code, "en") do |m, *args|
    file = "spec/examples/#{code.tr('-', '_')}.html"
    File.write file, m.call(*args).read unless File.exist? file
    File.read file
  end.at_least :once
end
