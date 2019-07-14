require "asciidoctor"
require "metanorma-iso"

module Asciidoctor
  module Iec
    class Converter < ISO::Converter

      register_for "iec"

      def metadata_author(node, xml)
        publishers = node.attr("publisher") || "IEC"
        publishers.split(/,[ ]?/).each do |p|
          xml.contributor do |c|
            c.role **{ type: "author" }
            c.organization { |a| organization(a, p) }
          end
        end
      end

      def metadata_publisher(node, xml)
        publishers = node.attr("publisher") || "IEC"
        publishers.split(/,[ ]?/).each do |p|
          xml.contributor do |c|
            c.role **{ type: "publisher" }
            c.organization { |a| organization(a, p) }
          end
        end
      end

      def metadata_copyright(node, xml)
        publishers = node.attr("publisher") || "IEC"
        publishers.split(/,[ ]?/).each do |p|
          xml.copyright do |c|
            c.from (node.attr("copyright-year") || Date.today.year)
            c.owner do |owner|
              owner.organization { |o| organization(o, p) }
            end
          end
        end
      end

      def make_preface(x, s)
        s.previous = boilerplate(x)
        super
      end

      def boilerplate(_x_orig)
        file = File.join(File.dirname(__FILE__),"iec_intro.xml")
        File.read(file, encoding: "UTF-8")
      end

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
