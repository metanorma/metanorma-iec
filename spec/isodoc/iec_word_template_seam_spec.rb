require "spec_helper"

RSpec.describe IsoDoc::Iec::WordConvert do
  # The base convert1 needs a full converter init; stub it so only the
  # IEC override (which records the stage template) runs.
  before do
    allow_any_instance_of(IsoDoc::Iso::WordConvert)
      .to receive(:convert1).and_return(nil)
  end

  it "records the stage template from the presentation XML during convert1" do
    xml = Nokogiri::XML(<<~XML)
      <iec-standard xmlns="https://www.metanorma.org/ns/iec">
        <bibdata><status><stage>30</stage></status></bibdata>
      </iec-standard>
    XML
    converter = described_class.new({})
    converter.send(:convert1, xml, "test", Dir.pwd)
    expect(converter.docx_template).to eq(:simple)
  end
end
