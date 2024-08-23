require "spec_helper"
require "fileutils"

RSpec.describe Metanorma::Iec do
  context "when xref_error.adoc compilation" do
    around do |example|
      FileUtils.rm_f "spec/assets/xref_error.err.html"
      example.run
      Dir["spec/assets/xref_error*"].each do |file|
        next if file.match?(/adoc$/)

        FileUtils.rm_f(file)
      end
    end

    it "generates error file" do
      expect do
        mock_pdf
        Metanorma::Compile
          .new
          .compile("spec/assets/xref_error.adoc", type: "iec", install_fonts: false)
      end.to(change { File.exist?("spec/assets/xref_error.err.html") }
              .from(false).to(true))
    end
  end

  it "Warns of illegal doctype" do
    FileUtils.rm_f "test.err.html"
    Asciidoctor.convert(<<~INPUT, backend: :iec, header_footer: true)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :no-isobib:
      :doctype: pizza

      text
    INPUT
    expect(File.read("test.err.html")).to include("pizza is not a recognised document type")
  end

  it "Warns of illegal function" do
    FileUtils.rm_f "test.err.html"
    Asciidoctor.convert(<<~INPUT, backend: :iec, header_footer: true)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :no-isobib:
      :function: pizza

      text
    INPUT
    expect(File.read("test.err.html")).to include("pizza is not a recognised document function")
  end

  it "warns of explicit style set on ordered list" do
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Clause
      [arabic]
      . A
    INPUT
    expect(File.read("test.err.html"))
      .to include("Style override set for ordered list")

    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      #{VALIDATING_BLANK_HDR}

      == Clause
      . A
    INPUT
    expect(File.read("test.err.html"))
      .not_to include("Style override set for ordered list")
  end

  it "aborts if stage not recognised" do
    FileUtils.rm_f "test.xml"
    FileUtils.rm_f "test.err.html"
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
      Asciidoctor.convert(input, *OPTIONS)
    rescue Error
    end
    expect(File.read("test.err.html"))
      .to include("Illegal document stage: A2CD")
    expect(File.exist?("test.xml")).to be false
  end

  it "Warns of illegal stage" do
    FileUtils.rm_f "test.err.html"
    Asciidoctor.convert(<<~INPUT, *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :no-isobib:
      :status: pizza

      text
    INPUT
    expect(File.read("test.err.html")).to include("Illegal document stage: pizza.00")

    FileUtils.rm_f "test.err.html"
    begin
    Asciidoctor.convert(<<~INPUT, *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :no-isobib:
      :status: 70

      text
    INPUT
    rescue Error
    end
    expect(File.read("test.err.html")).to include("Illegal document stage: 70.00")

    FileUtils.rm_f "test.err.html"
    begin
    Asciidoctor.convert(<<~INPUT, *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :no-isobib:
      :status: 60

      text
    INPUT
    rescue Error
    end
    expect(File.read("test.err.html")).not_to include("Illegal document stage: 60.00")
  end

  it "Warns of stage illegal for current type" do
    FileUtils.rm_f "test.err.html"
    begin
    Asciidoctor.convert(<<~INPUT, *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :no-isobib:
      :status: ADTR
      :doctype: technical-specification

      text
    INPUT
    rescue Error
    end
    expect(File.read("test.err.html")).to include("Illegal document stage: ADTR")
  end

  it "Warns of illegal substage" do
    FileUtils.rm_f "test.err.html"
    Asciidoctor.convert(<<~INPUT, *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :no-isobib:
      :status: 60
      :docsubstage: pizza

      text
    INPUT
    expect(File.read("test.err.html"))
      .to include("Illegal document stage: 60.pizza")

    FileUtils.rm_f "test.err.html"
    begin
      input = <<~INPUT
        = Document title
        Author
        :docfile: test.adoc
        :nodoc:
        :no-isobib:
        :status: 60
        :docsubstage: 54

        text
      INPUT
      expect do
        Asciidoctor.convert(input, *OPTIONS)
      end.not_to raise_error(Error)
    rescue Error
    end
    expect(File.exist?("test.xml")).to be false
    expect(File.read("test.err.html"))
      .to include("Illegal document stage: 60.54")

    FileUtils.rm_f "test.err.html"
    Asciidoctor.convert(<<~INPUT, *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :no-isobib:
      :status: 60
      :docsubstage: 60

      text
    INPUT
    expect(File.read("test.err.html"))
      .not_to include("Illegal document stage: 60.60")
  end
end
