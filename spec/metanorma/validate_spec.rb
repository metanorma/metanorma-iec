require "spec_helper"
require "fileutils"

RSpec.describe Metanorma::Iec do
  context "when xref_error.adoc compilation" do
    around do |example|
      FileUtils.rm_f "spec/assets/xref_error.err"
      example.run
      Dir["spec/assets/xref_error*"].each do |file|
        next if file.match?(/adoc$/)

        FileUtils.rm_f(file)
      end
    end

    it "generates error file" do
      expect do
        mock_pdf
        Metanorma::Compile.new.compile("spec/assets/xref_error.adoc",
                                       type: "iec", no_install_fonts: true)
      end.to(change { File.exist?("spec/assets/xref_error.err") }
              .from(false).to(true))
    end
  end

  it "Warns of illegal doctype" do
    FileUtils.rm_f "test.err"
    Asciidoctor.convert(<<~INPUT, backend: :iec, header_footer: true)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :no-isobib:
      :doctype: pizza

      text
    INPUT
    expect(File.read("test.err"))
      .to include "pizza is not a recognised document type"
  end

  it "Warns of illegal function" do
    FileUtils.rm_f "test.err"
    Asciidoctor.convert(<<~INPUT, backend: :iec, header_footer: true)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :no-isobib:
      :function: pizza

      text
    INPUT
    expect(File.read("test.err"))
      .to include "pizza is not a recognised document function"
  end

  it "warns of explicit style set on ordered list" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Clause
      [arabic]
      . A
    INPUT
    expect(File.read("test.err"))
      .to include "Style override set for ordered list"

    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Clause
      . A
    INPUT
    expect(File.read("test.err"))
      .not_to include "Style override set for ordered list"
  end

  it "aborts if stage not recognised" do
    FileUtils.rm_f "test.xml"
    FileUtils.rm_f "test.err"
    begin
      input = <<~INPUT
        = Document title
        Author
        :docfile: test.adoc
        :nodoc:
        :no-isobib:
        :docstage: A2CD

        text
      INPUT
      expect do
        Asciidoctor.convert(input, *OPTIONS)
      end.to raise_error(SystemExit)
    rescue SystemExit, RuntimeError
    end
    expect(File.read("test.err"))
      .to include "IEC Stage A2CD not recognised"
    expect(File.exist?("test.xml")).to be false
  end
end
