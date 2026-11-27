require "spec_helper"

RSpec.describe Metanorma::Iec::Processor do
  subject(:processor) { described_class.new }

  it "routes sts output through presentation XML" do
    expect(processor.use_presentation_xml(:sts)).to be true
  end

  it "keeps the base presentation routing for every other format" do
    routing = (processor.output_formats.keys - [:sts]).to_h do |format|
      [format, processor.use_presentation_xml(format)]
    end

    enabled = routing.select { |_, presentation| presentation }.keys
    expect(enabled).to contain_exactly(:html, :doc, :pdf)
  end
end

RSpec.describe Metanorma::Iec::Processor, "#output sts leg" do
  subject(:processor) { described_class.new }

  it "converts presentation XML with the native STS transformer, not mnconvert" do
    Dir.mktmpdir do |dir|
      pres = File.join(dir, "doc.presentation.xml")
      out = File.join(dir, "doc.sts.xml")
      File.write(pres, "<iec-standard/>")
      allow(Metanorma::Iec::Sts).to receive(:convert).and_return("<standard/>")
      expect(IsoDoc::Iso::StsConvert).not_to receive(:new)

      processor.output(nil, pres, out, :sts)

      expect(Metanorma::Iec::Sts).to have_received(:convert)
        .with("<iec-standard/>")
      expect(File.read(out, encoding: "utf-8")).to eq("<standard/>")
    end
  end
end
