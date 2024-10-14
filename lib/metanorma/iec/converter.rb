require "asciidoctor"
require "metanorma-iso"
require "metanorma/iso/converter"
require_relative "front"

module Metanorma
  module Iec
    class Converter < Iso::Converter
      XML_ROOT_TAG = "iec-standard".freeze
      XML_NAMESPACE = "https://www.metanorma.org/ns/iec".freeze

      register_for "iec"

      def init(node)
        super
        if @is_iev = node.attr("docnumber") == "60050"
          @vocab = true
          node.set_attr("docsubtype", "vocabulary")
        end
      end

      def boilerplate_file(x_orig)
        lang = case x_orig&.at("//bibdata/language")&.text
               when "fr" then "fr"
               else
                 "en"
               end
        File.join(@libdir, "boilerplate-#{lang}.adoc")
      end

      def id_prefix(_prefix, id)
        id.text
      end

      def doctype_validate(xmldoc)
        %w(international-standard technical-specification technical-report
           publicly-available-specification international-workshop-agreement
           guide interpretation-sheet).include? @doctype or
          @log.add("Document Attributes", nil,
                   "#{@doctype} is not a recognised document type")
        if function = xmldoc.at("//bibdata/ext/function")&.text
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

      def term_defs_boilerplate(div, source, term, preface, isodoc)
        super unless @is_iev
      end

      def terms_terms_cleanup(xmldoc)
        @is_iev and return
        super
      end

      def sections_names_pref_cleanup(xml)
        super
        @is_iev and replace_title(xml, "//introduction",
                                  @i18n&.introduction_iev)
      end

      # preserve ol/@type within boilerplate, not elsewhere in doc
      def ol_cleanup(doc)
        if doc.at("//metanorma-extension/semantic-metadata/" \
               "headless[text() = 'true']")
          doc.xpath("//ol[@explicit-type]").each do |x|
            x["type"] = x["explicit-type"]
            x.delete("explicit-type")
          end
        end
        ::Metanorma::Standoc::Converter.instance_method(:ol_cleanup).bind(self)
          .call(doc)
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

      def note_cleanup(xmldoc)
        super
        n = xmldoc.at("//tc-sc-officers-note") and
          xmldoc.at("//bibdata/ext").add_child(n.remove)
      end

      def image_name_validate(xmldoc); end

      def toc_cleanup(xmldoc)
        toc_iev_cleanup(xmldoc) if @is_iev
        super
      end

      def toc_iev_cleanup(xmldoc)
        iev_variant_titles(xmldoc)
      end

      def iev_variant_titles(xmldoc)
        id = xmldoc&.at("//bibdata/docidentifier[@type = 'ISO']")&.text
        m = /60050-(\d+)/.match(id) or return
        xmldoc.xpath("//sections/clause/terms/title").each_with_index do |t, i|
          num = "%02d" % [i + 1]
          t.next = "<variant-title type='toc'>" \
                   "#{@i18n.section_iev} #{m[1]}-#{num} &#x2013; " \
                   "#{t.children.to_xml}</variant-title>"
        end
      end

      # TODO remove when I adopt pubid-iec
      #
      def get_id_prefix(xmldoc)
        xmldoc.xpath("//bibdata/contributor[role/@type = 'publisher']" \
                     "/organization").each_with_object([]) do |x, prefix|
          x1 = x.at("abbreviation")&.text || x.at("name")&.text
          # (x1 == "IEC" and prefix.unshift("IEC")) or prefix << x1
          prefix << x1
        end
      end

      def document_scheme(node)
        node.attr("document-scheme")
      end

      def docidentifier_cleanup(xmldoc)
        prefix = get_id_prefix(xmldoc)
        id = xmldoc.at("//bibdata/docidentifier[@type = 'ISO']") or return
        id.content = id_prefix(prefix, id)
        id = xmldoc.at("//bibdata/ext/structuredidentifier/project-number") and
          id.content = id_prefix(prefix, id)
        %w(iso-with-lang iso-reference iso-undated).each do |t|
          id = xmldoc.at("//bibdata/docidentifier[@type = '#{t}']") and
            id.content = id_prefix(prefix, id)
        end
      end
    end
  end
end
