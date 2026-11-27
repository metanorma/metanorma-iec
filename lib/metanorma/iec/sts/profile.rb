# frozen_string_literal: true

require "metanorma/iec/document"

module Metanorma
  module Iec
    module Sts
      # The IEC publisher profile for the shared STS engine
      # (metanorma-document, Metanorma::Document::Sts) — the ISO/IEC
      # shared NISO STS 2.1 emitter/reader per the standing ruling:
      # IEC documents use the shared engine with IEC identity through
      # this profile, not a per-flavor STS engine.
      class Profile
        # IEC/ISO Coding Guidelines ed. 2.1 §4.3.2 coding profile; the
        # delivery-gate schema (NISO STS extended-1.2) accepts it.
        PROCESSING_META = <<~XML.chomp.freeze
          <processing-meta tagset-family="sts" base-tagset="interchange" table-model="xhtml" mathml-version="3.0" math-representation="mathml" terminology-model="tbx"><custom-meta-group><custom-meta><meta-name>iec_iso_coding_guidelines_edition</meta-name><meta-value>2.1</meta-value></custom-meta></custom-meta-group></processing-meta>
        XML

        def self.instance
          @instance ||= Metanorma::Document::Sts::Profile.new(
            name: :iec,
            org_abbrev: "IEC",
            reader_class: Metanorma::Iec::Document::Root,
            processing_meta: PROCESSING_META,
            term_classes: [Metanorma::IsoDocument::Terms::IsoTerm],
            class_overrides: {},
          ).freeze.tap { |p| Metanorma::Document::Sts::Profiles.register(p) }
        end
      end
    end
  end
end
