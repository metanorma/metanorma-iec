require_relative "init"
require "isodoc"

module IsoDoc
  module Iec
    class PresentationXMLConvert < IsoDoc::Iso::PresentationXMLConvert
      def clause(docxml)
        docxml.xpath(ns("//clause[not(ancestor::annex)] | "\
                        "//definitions | //references | "\
                        "//preface/introduction[clause]"))
          .each do |f|
          clause1(f)
        end
        docxml.xpath(ns("//terms")).each do |f|
          termclause1(f)
        end
      end

      def termclause1(elem)
        return clause1(elem) unless @is_iev
        return if @suppressheadingnumbers || elem["unnumbered"]

        lbl = @xrefs.anchor(elem["id"], :label, true) or return
        prefix_name(elem, " ", "#{lbl}#{clausedelim}", "title")
      end

      def clause1(elem)
        IsoDoc::PresentationXMLConvert.instance_method(:clause1).bind(self)
          .call(elem)
      end

      DICT_PATHS = { doctype_dict: "./ext/doctype", stage_dict: "./status/stage",
                     substage_dict: "./status/substage",
                     function_dict: "./ext/function",
                     horizontal_dict: "./ext/horizontal" }.freeze

      def bibdata_i18n(bib)
        fr = IsoDoc::Iec::I18n.new("fr", "Latn")
        en = IsoDoc::Iec::I18n.new("en", "Latn")
        [{ lang: "en", i18n: en }, { lang: "fr", i18n: fr }].each do |v|
          DICT_PATHS.each do |lbl, xpath|
            hash_translate(bib, v[:i18n].get[lbl.to_s], xpath, v[:lang])
          end
        end
      end

      def concept(docxml)
        @is_iev and concept_iev(docxml)
        super
      end

      def concept_iev(docxml)
        labels = @xrefs.get_anchors.each_with_object({}) do |(k, v), m|
          m[v[:label]] = k
        end
        docpart = docxml&.at(ns("//bibdata/ext/structuredidentifier/"\
                                "project-number/@part"))&.text or return
        docxml.xpath(ns("//concept/termref[@base = 'IEV']")).each do |t|
          concept_iev1(t, docpart, labels)
        end
      end

      def concept_iev1(termref, docpart, labels)
        /^#{docpart}-/.match?(termref["target"]) or return
        newtarget = labels[termref["target"]] or return
        termref.name = "xref"
        termref.delete("base")
        termref["target"] = newtarget
      end

      def terms(docxml)
        otherlang_designations(docxml)
        super
        merge_fr_into_en_term(docxml)
      end

      def merge_fr_into_en_term(docxml)
        return unless @is_iev

        docxml.xpath(ns("//term[@language = 'en'][@tag]")).each do |en|
          fr = docxml.at(ns("//term[@language = 'fr'][@tag = '#{en['tag']}']"))
          merge_fr_into_en_term1(en, fr) if fr
        end
        @xrefs.parse docxml
        docxml.xpath(ns("//term/name")).each(&:remove)
        term(docxml)
      end

      def merge_fr_into_en_term1(en_term, fr_term)
        dl = en_term&.at(ns("./dl[@type = 'other-lang']"))&.remove
        en_term << fr_term.remove.children
        en_term << dl if dl
        en_term["language"] = "en,fr"
        en_term.delete("tag")
      end

      def otherlang_designations(docxml)
        return unless @is_iev

        docxml.xpath(ns("//term")).each do |t|
          otherlang_designations1(t, t["language"]&.split(/,/) || %w(en fr))
        end
      end

      def extract_otherlang_designations(term, lgs)
        term.xpath(ns(".//preferred/expression[@language]"))
          .each_with_object([]) do |d, m|
          lg = d["language"]
          d.delete("language")
          next if lgs.include?(lg)

          p = d.parent
          designation_annotate(p, d.at(ns("./name")))
          m << { lang: lg, designation: p.remove }
        end
      end

      def otherlang_designations1(term, lgs)
        pr = extract_otherlang_designations(term, lgs)
        return if pr.empty?

        prefs = pr.map do |p|
          "<dt>#{p[:lang]}</dt><dd>#{p[:designation].to_xml}</dd>"
        end
        term << "<dl type='other-lang'>#{prefs.join}</dl>"
      end

      include Init
    end
  end
end
