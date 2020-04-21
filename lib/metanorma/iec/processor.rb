require "metanorma/processor"

module Metanorma
  module Iec
    def self.pdf_fonts
      ["Arial", "Times New Roman", "HanSans", "Courier"]
    end

    class Processor < Metanorma::Processor

      def initialize
        @short = :iec
        @input_format = :asciidoc
        @asciidoctor_backend = :iec
      end

      def output_formats
        super.merge(
          html: "html",
          doc: "doc",
          pdf: "pdf"
        )
      end

      def version
        "Metanorma::Iec #{Metanorma::Iec::VERSION}"
      end

      def input_to_isodoc(file, filename)
        Metanorma::Input::Asciidoc.new.process(file, filename, @asciidoctor_backend)
      end

      def output(isodoc_node, outname, format, options={})
        case format
        when :html
          IsoDoc::Iec::HtmlConvert.new(options).convert(outname, isodoc_node)
        when :doc
          IsoDoc::Iec::WordConvert.new(options).convert(outname, isodoc_node)
        when :pdf
          IsoDoc::Iec::PdfConvert.new(options).convert(outname, isodoc_node)
        else
          super
        end
      end
    end
  end
end
