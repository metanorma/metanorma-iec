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
        }
      end

      def version
        "Metanorma::Iec #{Metanorma::Iec::VERSION}"
      end

      def use_presentation_xml(ext)
        return true if ext == :sts

        super
      end

      def output(isodoc_node, inname, outname, format, options = {})
        options_preprocess(options)
        case format
        when :html
          IsoDoc::Iec::HtmlConvert.new(options)
            .convert(inname, isodoc_node, nil, outname)
        when :doc
          IsoDoc::Iec::WordConvert.new(options)
            .convert(inname, isodoc_node, nil, outname)
        when :pdf
          IsoDoc::Iec::PdfConvert.new(options)
            .convert(inname, isodoc_node, nil, outname)
        when :sts
          # Native metanorma-document STS transformer on the shared engine
          # (metanorma-iso#1760, metanorma-document#165 "iec via iso"); the
          # mnconvert leg (IsoDoc::Iso::StsConvert) is no longer used.
          File.write(outname, sts_xml(isodoc_node, inname), encoding: "utf-8")
        when :presentation
          IsoDoc::Iec::PresentationXMLConvert.new(options)
            .convert(inname, isodoc_node, nil, outname)
        else
          super
        end
      end

      private

      # The sts leg takes presentation XML: a String when the caller hands
      # it over, otherwise the file path (isodoc_node nil).
      def sts_xml(isodoc_node, inname)
        case isodoc_node
        when String then isodoc_node
        when nil then File.read(inname, encoding: "utf-8")
        else isodoc_node.to_xml
        end.then { |xml| Metanorma::Iso::Sts.convert(xml) }
      end
    end
  end
end
