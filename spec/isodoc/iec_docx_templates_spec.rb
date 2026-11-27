require "spec_helper"
require "isodoc/iec/docx_templates"

RSpec.describe IsoDoc::Iec::DocxTemplates do
  describe ".for_stage" do
    it "selects the simple template for stages 00 to 30" do
      %w[00 10 20 30].each do |stage|
        expect(described_class.for_stage(stage)).to eq(:simple)
      end
    end

    it "selects the DIS template from stage 40 on" do
      %w[40 50 60 90].each do |stage|
        expect(described_class.for_stage(stage)).to eq(:dis)
      end
    end

    it "reads the stage from a harmonized code such as 30.20" do
      expect(described_class.for_stage("30.20")).to eq(:simple)
      expect(described_class.for_stage("40.20")).to eq(:dis)
    end

    it "falls back to the DIS template when no stage is known" do
      expect(described_class.for_stage(nil)).to eq(:dis)
      expect(described_class.for_stage("")).to eq(:dis)
      expect(described_class.for_stage("PNW")).to eq(:dis)
    end
  end

  describe ".for_document" do
    def doc_with_stage(stage)
      Nokogiri::XML(<<~XML)
        <iec-standard xmlns="https://www.metanorma.org/ns/iec">
          <bibdata>
            <status><stage>#{stage}</stage></status>
          </bibdata>
        </iec-standard>
      XML
    end

    it "reads the bibdata stage from presentation XML" do
      expect(described_class.for_document(doc_with_stage("30"))).to eq(:simple)
      expect(described_class.for_document(doc_with_stage("40.20"))).to eq(:dis)
    end

    it "falls back to the DIS template when bibdata has no stage" do
      xml = Nokogiri::XML(<<~XML)
        <iec-standard xmlns="https://www.metanorma.org/ns/iec">
          <bibdata/>
        </iec-standard>
      XML
      expect(described_class.for_document(xml)).to eq(:dis)
    end
  end
end
