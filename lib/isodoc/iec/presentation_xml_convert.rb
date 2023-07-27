require_relative "init"
require "isodoc"
require_relative "../../relaton/render-iec/general"
require_relative "presentation_terms"

module IsoDoc
  module Iec
    class PresentationXMLConvert < IsoDoc::Iso::PresentationXMLConvert
      def i18n_init(lang, script, locale, i18nyaml = nil)
        super
        @i18n_lg = {}
        @i18n_lg["en"] = I18n.new("en", "Latn", i18nyaml: i18nyaml || @i18nyaml)
        @i18n_lg["fr"] = I18n.new("fr", "Latn", i18nyaml: i18nyaml || @i18nyaml)
        @i18n_lg["default"] = @i18n
      end

      def clause(docxml)
        docxml.xpath(ns("//clause[not(ancestor::annex)] | " \
                        "//definitions | //references | " \
                        "//preface/introduction[clause]"))
          .each do |f|
          f.parent.name == "annex" &&
            @xrefs.klass.single_term_clause?(f.parent) and next
          clause1(f)
        end
        docxml.xpath(ns("//terms")).each do |f|
          termclause1(f)
        end
      end

      def clause1(elem)
        IsoDoc::PresentationXMLConvert.instance_method(:clause1).bind(self)
          .call(elem)
      end

      DICT_PATHS = { doctype_dict: "./ext/doctype",
                     substage_dict: "./status/substage",
                     function_dict: "./ext/function",
                     horizontal_dict: "./ext/horizontal" }.freeze

      def bibdata_i18n(bib)
        [{ lang: "en", i18n: IsoDoc::Iec::I18n.new("en", "Latn") },
         { lang: "fr", i18n: IsoDoc::Iec::I18n.new("fr", "Latn") }].each do |v|
          DICT_PATHS.each do |lbl, xpath|
            hash_translate(bib, v[:i18n].get[lbl.to_s], xpath, v[:lang])
          end
          bibdata_i18n_stage(bib, bib.at(ns("./status/stage")),
                             bib.at(ns("./ext/doctype")),
                             lang: v[:lang], i18n: v[:i18n])
        end
      end

      def bibrenderer
        ::Relaton::Render::Iec::General.new(language: @lang,
                                            i18nhash: @i18n.get)
      end

      def rearrange_clauses(docxml)
        insert_foreword(docxml) # feeds preface_rearrange
        super
        insert_middle_title(docxml)
      end

      def insert_foreword(docxml)
        @meta.get[:doctype] == "Amendment" and return
        b = docxml.at(ns("//boilerplate/legal-statement")) or return
        unless f = docxml.at(ns("//preface/foreword"))
          ins = toc_title_insert_pt(docxml)
          f = ins.before(<<~CLAUSE).previous_element
            <foreword id='_#{UUIDTools::UUID.random_create}'> </foreword>
          CLAUSE
        end
        f.children.empty? and f.children = " "
        ins = f.at(ns("./title")) || f.children.first.before(" ").previous
        ins.next =
          "<clause type='boilerplate_legal'>#{to_xml(b.children)}</clause>"
      end

      def insert_middle_title(docxml)
        ins = docxml.at(ns("//preface/clause[@type = 'toc']")) or return
        title1, title2 = middle_title_parts
        title2out = ""
        title2 and title2out = <<~OUTPUT
          <p class="zzSTDTitle1">&#xa0;</p>
          <p class="zzSTDTitle2"><strong>#{title2}</strong></p>
        OUTPUT
        ins.next = <<~OUTPUT
          <pagebreak/><p class="zzSTDTitle1">#{@i18n.get['IEC']}</p>
          <p class="zzSTDTitle1">____________</p><p class="zzSTDTitle1">&#xa0;</p>
          <p class="zzSTDTitle1"><strong>#{title1&.upcase}</strong></p>#{title2out}
          <p class="zzSTDTitle1">&#xa0;</p>
        OUTPUT
      end

      def middle_title_parts
        title1 = @meta.get[:doctitlemain]&.sub(/\s+$/, "")
        @meta.get[:doctitleintro] and
          title1 = "#{@meta.get[:doctitleintro]} \u2014 #{title1}"
        title1, title2 = middle_title_part(title1, nil)
        title1&.empty? and title1 = nil
        [title1, title2]
      end

      def middle_title_part(title1, title2)
        if @meta.get[:doctitlepart]
          title1 += " \u2014"
          title2 = @meta.get[:doctitlepart]&.sub(/\s+$/, "")
          @meta.get[:doctitlepartlabel] and
            title2 = "#{@meta.get[:doctitlepartlabel]}: #{title2}"
        end
        [title1, title2]
      end

      def middle_title(docxml)
        s = docxml.at(ns("//sections")) or return
        title1, title2 = middle_title_parts
        title1 || title2 or return
        ret = ""
        title1 and ret = "<p class='zzSTDTitle1'><strong>#{title1}</strong></p>"
        title2 and ret += <<~TITLE
          <p class='zzSTDTitle1'>&#xa0;</p>
          <p class='zzSTDTitle2'><strong>#{title2}</strong><p>
        TITLE
        ret += "<p class='zzSTDTitle1'>&#xa0;</p>"
        s.children.first.previous = ret
      end

      include Init
    end
  end
end
