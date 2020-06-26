require "metanorma/processor"

module Metanorma
  module Iec
    def self.fonts_used
      {
        html: ["Arial", "Times New Roman", "HanSans", "Courier New"],
        doc: ["Arial", "Times New Roman", "HanSans", "Courier New"],
        pdf: ["Arial", "Times New Roman", "HanSans", "Courier New"],
      }
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

      def output(isodoc_node, inname, outname, format, options={})
        case format
        when :html
          IsoDoc::Iec::HtmlConvert.new(options).convert(inname, isodoc_node, nil, outname)
        when :doc
          IsoDoc::Iec::WordConvert.new(options).convert(inname, isodoc_node, nil, outname)
        when :pdf
          IsoDoc::Iec::PdfConvert.new(options).convert(inname, isodoc_node, nil, outname)
        when :presentation
          IsoDoc::Iec::PresentationXMLConvert.new(options).convert(inname, isodoc_node, nil, outname)
        else
          super
        end
      end
    end
  end
end
