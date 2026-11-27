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
        def self.instance
          @instance ||= Metanorma::Document::Sts::Profile.new(
            name: :iec,
            org_abbrev: "IEC",
            reader_class: Metanorma::Iec::Document::Root,
            term_classes: [Metanorma::IsoDocument::Terms::IsoTerm],
            class_overrides: {},
          ).freeze.tap { |p| Metanorma::Document::Sts::Profiles.register(p) }
        end
      end
    end
  end
end
