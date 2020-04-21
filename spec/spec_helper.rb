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
require "rexml/document"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

def strip_guid(x)
  x.gsub(%r{ id="_[^"]+"}, ' id="_"').gsub(%r{ target="_[^"]+"}, ' target="_"')
end

def xmlpp(x)
  s = ""
  f = REXML::Formatters::Pretty.new(2)
  f.compact = true
  f.write(REXML::Document.new(x),s)
  s
end

ASCIIDOC_BLANK_HDR = <<~"HDR"
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :no-isobib:

HDR

ISOBIB_BLANK_HDR = <<~"HDR"
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :no-isobib-cache:

HDR

FLUSH_CACHE_ISOBIB_BLANK_HDR = <<~"HDR"
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :flush-caches:

HDR

CACHED_ISOBIB_BLANK_HDR = <<~"HDR"
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:

HDR

LOCAL_CACHED_ISOBIB_BLANK_HDR = <<~"HDR"
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :local-cache:

HDR

VALIDATING_BLANK_HDR = <<~"HDR"
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :no-isobib:

HDR

TERMS_BOILERPLATE = <<~"BOILERPLATE"
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

BOILERPLATE =
  HTMLEntities.new.decode(
  File.read(File.join(File.dirname(__FILE__), "..", "lib", "asciidoctor", "iec", "iec_intro_en.xml"), encoding: "utf-8").
  gsub(/\{\{ agency \}\}/, "IEC").gsub(/\{\{ docyear \}\}/, Date.today.year.to_s).
  gsub(/\{% if unpublished %\}.*\{% endif %\}/m, "").
  gsub(/(?<=\p{Alnum})'(?=\p{Alpha})/, "’").
  gsub(/<p>/, "<p id='_'>").
  gsub(/<ol>/, "<ol id='_'>")
)

BOILERPLATE_LICENSE = <<~END
<license-statement>
  <clause>
    <title>Warning for CDs, CDVs and FDISs</title>
    <p id='_'>
      This document is not an IEC International Standard. It is distributed
      for review and comment. It is subject to change without notice and may
      not be referred to as an International Standard.
    </p>
    <p id='_'>
      Recipients of this draft are invited to submit, with their comments,
      notification of any relevant patent rights of which they are aware and
      to provide supporting documentation.
    </p>
  </clause>
</license-statement>
END

UNPUBLISHED_BOILERPLATE = BOILERPLATE.sub(/<\/boilerplate>/, "#{BOILERPLATE_LICENSE}</boilerplate>")


BLANK_HDR = <<~"HDR"
<?xml version="1.0" encoding="UTF-8"?>
<iec-standard xmlns="https://www.metanorma.org/ns/iec">
<bibdata type="standard">
  <contributor>
    <role type="author"/>
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
    <stage abbreviation="PPUB">60</stage>
    <substage abbreviation="PPUB">60</substage>
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
    <doctype>article</doctype>
  <editorialgroup>
    <technical-committee/>
    <subcommittee/>
    <workgroup/>
  </editorialgroup>
  <stagename>International standard</stagename>
  </ext>
</bibdata>
#{BOILERPLATE}
HDR

IEC_TITLE = <<~END
 <p class="zzSTDTitle1">INTERNATIONAL ELECTROTECHNICAL COMMISSION</p>
             <p class="zzSTDTitle1">____________</p>
             <p class="zzSTDTitle1">&#160;</p>
             <p class="zzSTDTitle1">
               <b/>
             </p>
             <p class="zzSTDTitle1">&#160;</p>
END

HTML_HDR = <<~END
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
             #{IEC_TITLE}
END

WORD_HDR = <<~END
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
END


def stub_fetch_ref(**opts)
  xml = ""

  hit = double("hit")
  expect(hit).to receive(:"[]").with("title") do
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

  expect(Isobib::IsoBibliography).to receive(:search).
    and_wrap_original do |search, *args|
    code = args[0]
    expect(code).to be_instance_of String
    xml = get_xml(search, code, opts)
    hit_pages
  end.at_least :once
end

private

def get_xml(search, code, opts)
  c = code.gsub(%r{[\/\s:-]}, "_").sub(%r{_+$}, "").downcase
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
  #expect(OpenURI).to receive(:open_uri).and_wrap_original do |m, *args|
  expect(Iev).to receive(:get).with(code, "en") do |m, *args|
    file = "spec/examples/#{code.tr('-', '_')}.html"
    File.write file, m.call(*args).read unless File.exist? file
    File.read file
  end.at_least :once
end

