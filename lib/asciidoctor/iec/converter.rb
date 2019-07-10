require "asciidoctor"
require "metanorma-iso"

module Asciidoctor
  module Iec
    class Converter << ::Asciidoctor::ISO::Converter

      register_for "iec"

      def html_converter(node)
        node.nil? ? IsoDoc::Iec::HtmlConvert.new({}) :
          IsoDoc::Iec::HtmlConvert.new(html_extract_attributes(node))
      end

      def doc_converter(node)
        node.nil? ? IsoDoc::Iec::WordConvert.new({}) :
          IsoDoc::Iec::WordConvert.new(doc_extract_attributes(node))
      end
    end
  end
end
