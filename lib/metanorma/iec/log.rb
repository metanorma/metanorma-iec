module Metanorma
  module Iec
    class Converter
      IEC_LOG_MESSAGES = {
        # rubocop:disable Naming/VariableNumber
        "IEC_1": { category: "Document Attributes",
                   error: "Illegal document stage: %s",
                   severity: 2 },
        "IEC_2": { category: "Document Attributes",
                   error: "%s is not a recognised document type",
                   severity: 2 },
        "IEC_3": { category: "Document Attributes",
                   error: "%s is not a recognised document function",
                   severity: 2 },
      }.freeze
      # rubocop:enable Naming/VariableNumber

      def log_messages
        super.merge(IEC_LOG_MESSAGES)
      end
    end
  end
end
