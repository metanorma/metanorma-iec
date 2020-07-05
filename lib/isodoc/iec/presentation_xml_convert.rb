require_relative "init"
require "isodoc"

module IsoDoc
  module Iec
    class PresentationXMLConvert < IsoDoc::Iso::PresentationXMLConvert
      def clause(docxml)
        docxml.xpath(ns("//clause[not(ancestor::boilerplate)]"\
                        "[not(ancestor::annex)] | "\
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
        return if @suppressheadingnumbers
        lbl = @xrefs.anchor(f['id'], :label, true) or return
        prefix_name(f, " ", "#{lbl}#{clausedelim}", "title")
      end

      def clause1(f)
        IsoDoc::PresentationXMLConvert.instance_method(:clause1).bind(self).
          call(f)
      end

      include Init
    end
  end
end

