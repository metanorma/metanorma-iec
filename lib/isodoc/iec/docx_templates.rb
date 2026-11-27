module IsoDoc
  module Iec
    # Stage-to-template selection for IEC DOCX output. Mirrors the ISO rule in
    # metanorma-iso lib/isodoc/iso/docx_style_mapping.rb: stages 00-30 use the
    # Simple template, stages 40 and later the DIS template. The IEC mapping is
    # an assumption until confirmed (CDV is stage 40.20, so it lands on :dis).
    module DocxTemplates
      SIMPLE_MAX_STAGE = 30

      module_function

      # stage_num: "30", "40", or a harmonized code such as "40.20".
      # Anything that does not carry a numeric stage (nil, "PNW") is :dis.
      def for_stage(stage_num)
        m = /\A(\d{2})(?:\.\d{2})?\z/.match(stage_num.to_s)
        return :dis unless m

        m[1].to_i <= SIMPLE_MAX_STAGE ? :simple : :dis
      end
    end
  end
end
