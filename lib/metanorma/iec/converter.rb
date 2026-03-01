require "asciidoctor"
require "metanorma-iso"
require "metanorma/iso/converter"
require_relative "front"

module Metanorma
  module Iec
    class Converter < Iso::Converter
      register_for "iec"

      def init(node)
        super
        if @is_iev = node.attr("docnumber") == "60050"
          @vocab = true
          node.set_attr("docsubtype", "vocabulary")
        end
      end

      def html_converter(node)
        if node.nil?
          IsoDoc::Iec::HtmlConvert.new({})
        else
          IsoDoc::Iec::HtmlConvert.new(html_extract_attributes(node))
        end
      end

      def doc_converter(node)
        if node.nil?
          IsoDoc::Iec::WordConvert.new({})
        else
          IsoDoc::Iec::WordConvert.new(doc_extract_attributes(node))
        end
      end

      def pdf_converter(node)
        return if node.attr("no-pdf")

        if node.nil?
          IsoDoc::Iec::PdfConvert.new({})
        else
          IsoDoc::Iec::PdfConvert.new(pdf_extract_attributes(node))
        end
      end

      def presentation_xml_converter(node)
        if node.nil?
          IsoDoc::Iec::PresentationXMLConvert.new({})
        else
          IsoDoc::Iec::PresentationXMLConvert
            .new(doc_extract_attributes(node)
            .merge(output_formats: ::Metanorma::Iec::Processor
              .new.output_formats))
        end
      end

      def note(note)
        if note.title == "Note from TC/SC Officers"
          noko do |xml|
            xml.tc_sc_officers_note do |c|
              wrap_in_para(note, c)
            end
          end
        else
          super
        end
      end

      def document_scheme(node)
        node.attr("document-scheme")
      end
    end
  end
end

require_relative "log"
