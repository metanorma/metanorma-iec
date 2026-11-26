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
RSpec.describe "IEC STS golden parity" do
  before do
    sequence = (1..).each
    allow(Metanorma::Utils).to receive(:random_uuid) do
      format("00000000-0000-4000-8000-%012d", sequence.next)
    end
  end

  fixtures = File.expand_path("../../fixtures/sts", __dir__)
  niso_xsd = File.join(Gem::Specification.find_by_name("sts").gem_dir,
                       "reference-docs/NISO-STS-extended-1-MathML3-XSD",
                       "NISO-STS-extended-1-mathml3.xsd")
  schema = Nokogiri::XML::Schema.from_document(Nokogiri::XML(File.open(niso_xsd)))
  processor = Metanorma::Iec::Processor.new

  # The STS output embeds each figure as base64, so the goldens pin the
  # placeholder bytes below. The real RICE figures (~840 KB) are not
  # vendored; the goldens therefore do not cover real-figure output.
  placeholder_png = Base64.decode64(
    "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=",
  )

  def compile_sts(processor, source, dir, placeholder_png)
    name = File.basename(source, ".adoc")
    adoc = File.join(dir, "#{name}.adoc")
    File.write(adoc, File.read(source, encoding: "utf-8"), encoding: "utf-8")
    File.read(adoc, encoding: "utf-8").scan(/^image::([^\[]+)\[/) do |(target)|
      path = File.join(dir, "images", target)
      FileUtils.mkdir_p(File.dirname(path))
      File.binwrite(path, placeholder_png)
    end
    semantic_path = File.join(dir, "#{name}.xml")
    File.write(semantic_path,
               processor.input_to_isodoc(File.read(adoc, encoding: "utf-8"), adoc),
               encoding: "utf-8")
    sts_path = File.join(dir, "#{name}.sts.xml")
    processor.output(File.read(semantic_path, encoding: "utf-8"),
                     semantic_path, sts_path, :sts)
    File.read(sts_path, encoding: "utf-8")
  end

  %w[iec-rice-en iec-rice-fr synthetic-techreport].each do |slug|
    describe slug do
      source = File.join(fixtures, "inputs", "#{slug}.adoc")
      golden_path = File.join(fixtures, "golden", "#{slug}.sts.xml")

      it "reproduces the golden STS output" do
        Dir.mktmpdir do |dir|
          current = compile_sts(processor, source, dir, placeholder_png)
          if ENV["STS_GOLDEN_CAPTURE"]
            File.write(golden_path, current, encoding: "utf-8")
          end
          expect(current).to eq(File.read(golden_path, encoding: "utf-8"))
        end
      end

      it "validates against the NISO STS extended XSD" do
        Dir.mktmpdir do |dir|
          doc = Nokogiri::XML(compile_sts(processor, source, dir, placeholder_png))
          expect(schema.validate(doc).map(&:to_s)).to be_empty
        end
      end
    end
  end
end
