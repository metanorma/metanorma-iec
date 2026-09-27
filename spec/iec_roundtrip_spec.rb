# frozen_string_literal: true

require "bundler/setup"
require "rspec/matchers"
require "metanorma/iec/document"
require_relative "support/roundtrip_helper"
require_relative "support/shared_roundtrip_examples"

RSpec.describe "IEC document XML round-trip" do
  it_behaves_like "xml round-trip", flavor_dir: "iec",
                                    doc_class: Metanorma::Iec::Document::Root
end
