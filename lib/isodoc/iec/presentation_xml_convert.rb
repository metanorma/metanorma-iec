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

      include Init
    end
  end
end
