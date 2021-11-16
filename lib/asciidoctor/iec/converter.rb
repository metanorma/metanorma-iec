require "asciidoctor"
require "metanorma-iso"
require_relative "./front"

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
          @log.add("Document Attributes", nil,
                   "#{doctype} is not a recognised document type")
        if function = xmldoc&.at("//bibdata/ext/function")&.text
          %w(emc quality-assurance safety environment).include? function or
            @log.add("Document Attributes", nil,
                     "#{function} is not a recognised document function")
        end
      end

      def validate(doc)
        content_validate(doc)
        schema_validate(formattedstr_strip(doc.dup),
                        File.join(File.dirname(__FILE__), "iec.rng"))
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
          IsoDoc::Iec::PdfConvert.new(doc_extract_attributes(node))
        end
      end

      def presentation_xml_converter(node)
        if node.nil?
          IsoDoc::Iec::PresentationXMLConvert.new({})
        else
          IsoDoc::Iec::PresentationXMLConvert.new(doc_extract_attributes(node))
        end
      end

      def norm_ref_preface(f)
        return super unless @is_iev

        f.at("./title").next =
          "<p>#{@i18n.norm_empty_pref}</p>"
      end

      def term_defs_boilerplate(div, source, term, preface, isodoc)
        return super unless @is_iev
      end

      def sections_names_cleanup(xml)
        super
        @is_iev and replace_title(xml, "//introduction", @i18n&.introduction_iev)
      end

      def note(note)
        if note.title == "Note from TC/SC Officers"
          noko do |xml|
            xml.tc_sc_officers_note do |c|
              wrap_in_para(note, c)
            end
          end.join("\n")
        else
          super
        end
      end

      def note_cleanup(xmldoc)
        super
        n = xmldoc.at("//tc-sc-officers-note") and
          xmldoc.at("//bibdata/ext").add_child(n.remove)
      end

      def image_name_validate(xmldoc); end
    end
  end
end
