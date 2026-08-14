# frozen_string_literal: true

# Self-contained: avoids pulling in the gem's full spec_helper (which
# may load unrelated code with pre-existing pubid-* dependency issues).
require "bundler/setup"
require "metanorma/iec/document"

RSpec.describe "Metanorma::Iec::Document namespace" do
  describe "canonical namespace" do
    it "exposes Metanorma::Iec::Document as a Module" do
      expect(Metanorma::Iec::Document).to be_a(Module)
    end

    it "exposes Root with the canonical name" do
      expect(Metanorma::Iec::Document::Root.name)
        .to eq("Metanorma::Iec::Document::Root")
    end

    it "Root is a lutaml Serializable" do
      expect(Metanorma::Iec::Document::Root < Lutaml::Model::Serializable).to be(true)
    end
  end

  describe "backwards-compat alias" do
    it "Metanorma::IecDocument aliases to the new namespace" do
      expect(Metanorma::IecDocument).to eq(Metanorma::Iec::Document)
    end

    it "the alias preserves class identity" do
      expect(Metanorma::IecDocument::Root.equal?(
               Metanorma::Iec::Document::Root)).to be(true)
    end
  end

  describe "parent namespace" do
    it "Metanorma::Standoc::Document is available" do
      expect(Metanorma::Standoc::Document).to be_a(Module)
    end

    it "Metanorma::StandardDocument alias is available" do
      expect(Metanorma::StandardDocument).to eq(Metanorma::Standoc::Document)
    end
  end
end
