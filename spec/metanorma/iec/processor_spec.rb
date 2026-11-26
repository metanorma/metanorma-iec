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
