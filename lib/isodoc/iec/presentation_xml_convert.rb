require_relative "init"
require "isodoc"

module IsoDoc
  module Iec
    class PresentationXMLConvert < IsoDoc::Iso::PresentationXMLConvert
      def clause(docxml)
        docxml.xpath(ns("//clause[not(ancestor::annex)] | "\
                        "//definitions | //references | "\
                        "//preface/introduction[clause]")).
        each do |f|
          clause1(f)
        end
        docxml.xpath(ns("//terms")).each do |f|
          termclause1(f)
        end
      end

      def termclause1(f)
        return clause1(f) unless @is_iev
        return if @suppressheadingnumbers || f["unnumbered"]
        lbl = @xrefs.anchor(f['id'], :label, true) or return
        prefix_name(f, " ", "#{lbl}#{clausedelim}", "title")
      end

      def clause1(f)
        IsoDoc::PresentationXMLConvert.instance_method(:clause1).bind(self).
          call(f)
      end

      def bibdata_i18n(b)
        fr = IsoDoc::Iec::I18n.new("fr", "Latn")
        en = IsoDoc::Iec::I18n.new("en", "Latn")
        [{ lang: "en", i18n: en }, { lang: "fr", i18n: fr }].each do |v|
          hash_translate(b, v[:i18n].get["doctype_dict"], "./ext/doctype", v[:lang])
          hash_translate(b, v[:i18n].get["stage_dict"], "./status/stage", v[:lang])
          hash_translate(b, v[:i18n].get["substage_dict"], "./status/substage", v[:lang])
          hash_translate(b, v[:i18n].get["function_dict"], "./ext/function", v[:lang])
          hash_translate(b, v[:i18n].get["horizontal_dict"], "./ext/horizontal", v[:lang])
        end
      end

      include Init
    end
  end
end

