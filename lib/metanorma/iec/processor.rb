require "metanorma/processor"

module Metanorma
  module Iec
    class Processor < Metanorma::Processor
      def initialize # rubocop:disable Lint/MissingSuper
        @short = :iec
        @input_format = :asciidoc
        @asciidoctor_backend = :iec
      end

      def output_formats
        super.merge(
          html: "html",
          doc: "doc",
          pdf: "pdf",
          sts: "sts.xml",
        )
      end

      def fonts_manifest
        {
          "Arial" => nil,
          "Times New Roman" => nil,
          "STIX Two Math" => nil,
          "Source Han Sans" => nil,
          "Source Han Sans Normal" => nil,
          "Courier New" => nil,
          "Noto Sans" => nil,
          "Noto Sans HK" => nil,
          "Noto Sans JP" => nil,
          "Noto Sans KR" => nil,
          "Noto Sans SC" => nil,
          "Noto Sans TC" => nil,
          "Noto Sans Mono" => nil,
          "Noto Sans Mono CJK HK" => nil,
          "Noto Sans Mono CJK JP" => nil,
          "Noto Sans Mono CJK KR" => nil,
          "Noto Sans Mono CJK SC" => nil,
          "Noto Sans Mono CJK TC" => nil,
        }
      end

      def version
        "Metanorma::Iec #{Metanorma::Iec::VERSION}"
      end

      def output(isodoc_node, inname, outname, format, options = {})
        case format
        when :html
          IsoDoc::Iec::HtmlConvert.new(options).convert(inname, isodoc_node,
                                                        nil, outname)
        when :doc
          IsoDoc::Iec::WordConvert.new(options).convert(inname, isodoc_node,
                                                        nil, outname)
        when :pdf
          IsoDoc::Iec::PdfConvert.new(options).convert(inname, isodoc_node,
                                                       nil, outname)
        when :sts
          IsoDoc::Iso::StsConvert.new(options).convert(inname, isodoc_node,
                                                       nil, outname)
        when :presentation
          IsoDoc::Iec::PresentationXMLConvert.new(options)
            .convert(inname, isodoc_node, nil, outname)
        else
          super
        end
      end
    end
  end
end
