require "spec_helper"
require "fileutils"

RSpec.describe Asciidoctor::Iec do

it "Warns of illegal doctype" do
    expect { Asciidoctor.convert(<<~"INPUT", backend: :iec, header_footer: true) }.to output(/pizza is not a recognised document type/).to_stderr
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :no-isobib:
  :doctype: pizza

  text
  INPUT
end

it "Warns of illegal script" do
    expect { Asciidoctor.convert(<<~"INPUT", backend: :iec, header_footer: true) }.to output(/pizza is not a recognised script/).to_stderr
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :no-isobib:
  :script: pizza

  text
  INPUT
end

it "Warns of illegal stage" do
    expect { Asciidoctor.convert(<<~"INPUT", backend: :iec, header_footer: true) }.to output(/pizza is not a recognised stage/).to_stderr
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :no-isobib:
  :status: pizza

  text
  INPUT
end

it "Warns of illegal substage" do
    expect { Asciidoctor.convert(<<~"INPUT", backend: :iec, header_footer: true) }.to output(/pizza is not a recognised substage/).to_stderr
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :no-isobib:
  :status: 60
  :docsubstage: pizza

  text
  INPUT
end

it "Warns of illegal iteration" do
    expect { Asciidoctor.convert(<<~"INPUT", backend: :iec, header_footer: true) }.to output(/pizza is not a recognised iteration/).to_stderr
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :no-isobib:
  :status: 60
  :iteration: pizza

  text
  INPUT
end

it "Warns of illegal script" do
    expect { Asciidoctor.convert(<<~"INPUT", backend: :iec, header_footer: true) }.to output(/pizza is not a recognised script/).to_stderr
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :no-isobib:
  :script: pizza

  text
  INPUT
end


it "Warning if invalid technical committee type" do
  expect { Asciidoctor.convert(<<~"INPUT", backend: :iec, header_footer: true) }.to output(%r{invalid technical committee type}).to_stderr
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :technical-committee-type: X
  :no-isobib:

  INPUT
end

it "Warning if invalid subcommittee type" do
  expect { Asciidoctor.convert(<<~"INPUT", backend: :iec, header_footer: true) }.to output(%r{invalid subcommittee type}).to_stderr
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :subcommittee-type: X
  :no-isobib:

  INPUT
end

it "Warning if invalid subcommittee type" do
  expect { Asciidoctor.convert(<<~"INPUT", backend: :iec, header_footer: true) }.to output(%r{invalid subcommittee type}).to_stderr
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :subcommittee-type: X
  :no-isobib:

  INPUT
end

it "validates document against ISO XML schema" do
  expect { Asciidoctor.convert(<<~"INPUT", backend: :iec, header_footer: true) }.to output(%r{value of attribute "align" is invalid; must be equal to}).to_stderr
  #{VALIDATING_BLANK_HDR}

  [align=mid-air]
  Para
  INPUT
end

end
