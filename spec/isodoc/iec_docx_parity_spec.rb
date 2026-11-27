require "spec_helper"
require "isodoc/iec/docx_parity"

RSpec.describe IsoDoc::Iec::DocxParity do
  describe ".report_lines" do
    it "reports MATCH for identical token sequences" do
      lines = described_class.report_lines(%w[H1 P P], %w[H1 P P])
      expect(lines).to eq(["MATCH"])
    end

    it "reports one missing paragraph without cascading later positions" do
      expected = %w[H1 P1 P2 P3 P4]
      actual = %w[H1 P2 P3 P4]
      lines = described_class.report_lines(expected, actual)
      expect(lines).to eq(["- 2: P1"])
    end

    it "reports an inserted token with its actual position" do
      lines = described_class.report_lines(%w[H1 P], %w[H1 X P])
      expect(lines).to eq(["+ 2: X"])
    end

    it "treats reordered repeated tokens as a multiset delta" do
      lines = described_class.report_lines(%w[A B A], %w[B A C])
      expect(lines).to include("- 1: A").or include("- 3: A")
      expect(lines.grep(/\+ 3: C/)).not_to be_empty
    end
  end
end
