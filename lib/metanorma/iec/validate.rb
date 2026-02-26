module Metanorma
  module Iec
    class Validate < ::Metanorma::Iso::Validate
      extend Forwardable

      def_delegators :@converter, *delegator_methods

      def doctype_validate(xmldoc)
        %w(international-standard technical-specification technical-report
           publicly-available-specification international-workshop-agreement
           guide interpretation-sheet).include? @doctype or
          @log.add("IEC_2", nil, params: [@doctype])
        if function = xmldoc.at("//bibdata/ext/function")&.text
          %w(emc quality-assurance safety environment).include? function or
            @log.add("IEC_3", nil, params: [function])
        end
      end

      def schema_file
        "iec.rng"
      end

      def image_name_validate(xmldoc); end
    end
  end
end
