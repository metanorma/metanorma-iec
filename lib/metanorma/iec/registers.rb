# frozen_string_literal: true

require "lutaml/model"

module Metanorma
  module Iec
    # IEC's lutaml-model register: creates the :iec_document context with
    # the ISO document register as fallback. Formerly
    # Metanorma::Registers::Setup.setup_iec_register in metanorma-
    # document; IEC adds no substitutions over the ISO sections.
    module Registers
      module_function

      def setup
        reg = Lutaml::Model::Register.new(:iec_document,
                                          fallback: [:iso_document])
        Lutaml::Model::GlobalRegister.register(reg)
      end
    end
  end
end
