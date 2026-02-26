module Metanorma
  module Iec
    class Cleanup < ::Metanorma::Iso::Cleanup
      extend Forwardable

      def_delegators :@converter, *delegator_methods

      def copied_instance_variables
        super + %i[is_iev]
      end

      def boilerplate_file(x_orig)
        lang = case x_orig&.at("//bibdata/language")&.text
               when "fr" then "fr"
               else
                 "en"
               end
        File.join(@libdir, "boilerplate-#{lang}.adoc")
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
        doc.xpath("//ol[@type]").each { |x| x.delete("type") }
        if doc.at("//metanorma-extension/semantic-metadata/" \
               "headless[text() = 'true']")
          doc.xpath("//ol[@explicit-type]").each do |x|
            x["type"] = x["explicit-type"]
            x.delete("explicit-type")
          end
        end
        ::Metanorma::Standoc::Cleanup.instance_method(:ol_cleanup).bind(self)
          .call(doc)
      end

      def note_cleanup(xmldoc)
        super
        n = xmldoc.at("//tc-sc-officers-note") and
          xmldoc.at("//bibdata/ext").add_child(n.remove)
      end

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
          t.next = "<variant-title #{add_id_text} type='toc'>" \
                   "#{@i18n.section_iev} #{m[1]}-#{num} &#x2013; " \
                   "#{t.children.to_xml}</variant-title>"
        end
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

      # TODO remove when I adopt pubid-iec
      def get_id_prefix(xmldoc)
        xmldoc.xpath("//bibdata/contributor[role/@type = 'publisher']" \
                     "/organization").each_with_object([]) do |x, prefix|
          x1 = x.at("abbreviation")&.text || x.at("name")&.text
          # (x1 == "IEC" and prefix.unshift("IEC")) or prefix << x1
          prefix << x1
        end
      end

      def id_prefix(_prefix, id)
        id.text
      end
    end
  end
end
