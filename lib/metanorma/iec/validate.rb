module Metanorma
  module Iec
    class Validate < ::Metanorma::Iso::Validate
      extend Forwardable

      IEC_DOCTYPES = %w[
        standard international-standard technical-specification
        technical-report publicly-available-specification
        international-workshop-agreement guide interpretation-sheet
        directive white-paper technology-report
        social-technology-trend-report component-specification
        systems-reference-document operational-document
        conformity-assessment test-report-form amendment corrigendum
      ].freeze

      IEC_FUNCTIONS = %w[
        emc quality-assurance safety environment
      ].freeze

      def doctype_validate(xmldoc)
        IEC_DOCTYPES.include?(@doctype) or
          @log.add("IEC_2", nil, params: [@doctype])
        if function = xmldoc.at("//bibdata/ext/function")&.text
          IEC_FUNCTIONS.include?(function) or
            @log.add("IEC_3", nil, params: [function])
        end
      end

      def content_validate(doc)
        super
        doctype_validate(doc)
        schema_validate(formattedstr_strip(doc.dup), schema_location)
      end

      # IEC reports doctype/function findings as IEC_2/IEC_3; suppress the
      # ISO model rule that would duplicate doctype findings with ISO_5.
      def validation_profile
        Metanorma::Iso::Validation::Profile.new(
          name: "iec", except_codes: ["ISO_5"],
        )
      end

      def schema_file
        "iec.rng"
      end

      def image_name_validate(xmldoc); end
    end
  end
end
