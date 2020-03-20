require "spec_helper"
require "fileutils"

RSpec.describe Asciidoctor::Iec do

it "Warns of illegal doctype" do
    FileUtils.rm_f "test.err"
    Asciidoctor.convert(<<~"INPUT", backend: :iec, header_footer: true) 
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :no-isobib:
  :doctype: pizza

  text
  INPUT
    expect(File.read("test.err")).to include "pizza is not a recognised document type"
end
end
