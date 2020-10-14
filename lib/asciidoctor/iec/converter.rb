require "asciidoctor"
require "metanorma-iso"
require_relative "./front.rb"

module Asciidoctor
  module Iec
    class Converter < ISO::Converter
      XML_ROOT_TAG = "iec-standard".freeze
      XML_NAMESPACE = "https://www.metanorma.org/ns/iec".freeze

      register_for "iec"

      def init(node)
        super
        @is_iev = node.attr("docnumber") == "60050"
      end

      def boilerplate_file(x_orig)
        lang = case x_orig&.at("//bibdata/language")&.text
               when "fr" then "fr"
               else
                 "en"
               end
        File.join(@libdir, "iec_intro_#{lang}.xml")
      end

      def doctype_validate(xmldoc)
        doctype = xmldoc&.at("//bibdata/ext/doctype")&.text
        %w(international-standard technical-specification technical-report 
        publicly-available-specification international-workshop-agreement 
        guide interpretation-sheet).include? doctype or
        @log.add("Document Attributes", nil, "#{doctype} is not a recognised document type")
      end

      def validate(doc)
        content_validate(doc)
        schema_validate(formattedstr_strip(doc.dup),
                        File.join(File.dirname(__FILE__), "iec.rng"))
      end

      def html_converter(node)
        node.nil? ? IsoDoc::Iec::HtmlConvert.new({}) :
          IsoDoc::Iec::HtmlConvert.new(html_extract_attributes(node))
      end

      def doc_converter(node)
        node.nil? ? IsoDoc::Iec::WordConvert.new({}) :
          IsoDoc::Iec::WordConvert.new(doc_extract_attributes(node))
      end

      def pdf_converter(node)
        return if node.attr("no-pdf")
        node.nil? ? IsoDoc::Iec::PdfConvert.new({}) :
          IsoDoc::Iec::PdfConvert.new(doc_extract_attributes(node))
      end

      def presentation_xml_converter(node)
        node.nil? ? IsoDoc::Iec::PresentationXMLConvert.new({}) :
          IsoDoc::Iec::PresentationXMLConvert.new(doc_extract_attributes(node))
      end
        
      def norm_ref_preface(f)
        return super unless @is_iev
        f.at("./title").next =
          "<p>#{@i18n.norm_empty_pref}</p>"
      end

      def term_defs_boilerplate(div, source, term, preface, isodoc)
        return super unless @is_iev
      end

      def sts_converter(node)
      end

      def sections_names_cleanup(x)
        super
        @is_iev and replace_title(x, "//introduction", @i18n&.introduction_iev)
      end
    end
  end
end
