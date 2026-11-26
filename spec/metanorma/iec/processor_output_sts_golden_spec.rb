require "spec_helper"
require "nokogiri"
require "sts"
require "tmpdir"
require "base64"
require "fileutils"

# Golden STS parity for IEC: each corpus document must reproduce its
# committed STS output byte-for-byte through Processor#output(:sts), and
# that output must validate against the NISO STS extended XSD. The goldens
# pin the behaviour the shared STS engine must preserve when IEC moves onto
# it (metanorma-iso#1760 / metanorma-document#165, epic #165 "iec via iso").
#
# Re-capture after an intended change with STS_GOLDEN_CAPTURE=1.
RSpec.describe Metanorma::Iec::Processor, "#output" do
  before do
    sequence = (1..).each
    allow(Metanorma::Utils).to receive(:random_uuid) do
      format("00000000-0000-4000-8000-%012d", sequence.next)
    end
  end

  let(:processor) { described_class.new }

  let(:schema) do
    niso_xsd = File.join(Gem::Specification.find_by_name("sts").gem_dir,
                         "reference-docs/NISO-STS-extended-1-MathML3-XSD",
                         "NISO-STS-extended-1-mathml3.xsd")
    Nokogiri::XML::Schema.from_document(Nokogiri::XML(File.open(niso_xsd)))
  end

  # The STS output embeds each figure as base64, so the goldens pin the
  # placeholder bytes below. The real RICE figures (~840 KB) are not
  # vendored; the goldens therefore do not cover real-figure output.
  let(:placeholder_png) do
    Base64.decode64(<<~BASE64.delete("\n"))
      iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB
      0C8AAAAASUVORK5CYII=
    BASE64
  end

  def fixture(*parts)
    File.expand_path(File.join("../../fixtures/sts", *parts), __dir__)
  end

  def stage_source(source, dir)
    adoc = File.join(dir, File.basename(source))
    File.write(adoc, File.read(source, encoding: "utf-8"), encoding: "utf-8")
    File.read(adoc, encoding: "utf-8").scan(/^image::([^\[]+)\[/) do |(target)|
      path = File.join(dir, "images", target)
      FileUtils.mkdir_p(File.dirname(path))
      File.binwrite(path, placeholder_png)
    end
    adoc
  end

  def write_sts(adoc)
    base = adoc.delete_suffix(".adoc")
    semantic = "#{base}.xml"
    sts = "#{base}.sts.xml"
    input = File.read(adoc, encoding: "utf-8")
    File.write(semantic, processor.input_to_isodoc(input, adoc),
               encoding: "utf-8")
    semantic_xml = File.read(semantic, encoding: "utf-8")
    processor.output(semantic_xml, semantic, sts, :sts)
  end

  def compile_sts(source)
    Dir.mktmpdir do |dir|
      adoc = stage_source(source, dir)
      Dir.chdir(dir) { expect { write_sts(adoc) }.not_to raise_error }
      sts = "#{adoc.delete_suffix('.adoc')}.sts.xml"
      expect(File.exist?(sts)).to be true
      File.read(sts, encoding: "utf-8")
    end
  end

  def capture_or_skip(current, golden_path)
    File.write(golden_path, current, encoding: "utf-8")
    skip "golden captured; rerun without STS_GOLDEN_CAPTURE to compare"
  end

  %w[iec-rice-en iec-rice-fr synthetic-techreport].each do |slug|
    describe slug do
      let(:source) { fixture("inputs", "#{slug}.adoc") }
      let(:golden_path) { fixture("golden", "#{slug}.sts.xml") }

      it "reproduces the golden STS output" do
        current = compile_sts(source)
        capture_or_skip(current, golden_path) if ENV["STS_GOLDEN_CAPTURE"]
        expect(current).to eq(File.read(golden_path, encoding: "utf-8"))
      end

      it "validates against the NISO STS extended XSD" do
        doc = Nokogiri::XML(compile_sts(source))
        expect(schema.validate(doc).map(&:to_s)).to be_empty
      end
    end
  end
end
