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

      def clause1(elem)
        if elem.name == "terms" && @is_iev then iev_termclause1(elem)
        else
          IsoDoc::PresentationXMLConvert.instance_method(:clause1).bind(self)
            .call(elem)
        end
      end

      DICT_PATHS = { doctype_dict: ["./ext/doctype",
                                    "//presentation-metadata/doctype-alias"],
                     substage_dict: ["./status/substage", nil],
                     function_dict: ["./ext/function", nil],
                     horizontal_dict: ["./ext/horizontal", nil] }.freeze

      def bibdata_i18n(bib)
        [{ lang: "en", i18n: IsoDoc::Iec::I18n.new("en", "Latn") },
         { lang: "fr", i18n: IsoDoc::Iec::I18n.new("fr", "Latn") }].each do |v|
          DICT_PATHS.each do |lbl, xpath|
            hash_translate(bib, v[:i18n].get[lbl.to_s], xpath[0], xpath[1],
                           v[:lang])
          end
          bibdata_i18n_stage(bib, bib.at(ns("./status/stage")),
                             bib.at(ns("./ext/doctype")),
                             lang: v[:lang], i18n: v[:i18n])
        end
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
            <foreword #{add_id_text}> </foreword>
          CLAUSE
        end
        insert_foreword_boilerplate(f, b)
      end

      def insert_foreword_boilerplate(elem, boilerplate)
        elem.children.empty? and elem.children = " "
        ins = elem.at(ns("./title")) || elem.children.first.before(" ").previous
        ins.next = <<~CLAUSE
          <clause type='boilerplate_legal' #{add_id_text}>#{to_xml(boilerplate.children)}</clause>
        CLAUSE
      end

      def insert_middle_title(docxml)
        ins = docxml.at(ns("//preface/clause[@type = 'toc']")) or return
        title = populate_template(preface_title_template, nil) or return
        ins.next = title
      end

      def preface_title_template
        <<~OUTPUT
          <pagebreak/><p class="zzSTDTitle1">{{ labels["IEC"] }}</p>
          <p class="zzSTDTitle1">____________</p><p class="zzSTDTitle1">&#xa0;</p>
          <p class='zzSTDTitle1'><strong>{% if doctitleintro %}{{ doctitleintro | upcase -}}
          &#x2014; {% endif %}{{ doctitlemain | upcase }}{% if doctitlepart %} &#x2014;{% endif %}</strong></p>
          {% if doctitlepart %}<p class='zzSTDTitle1'>&#xa0;</p>
          <p class='zzSTDTitle2'><strong>{% if doctitlepartlabel %}{{ doctitlepartlabel }}: {% endif -%}
          {{ doctitlepart }}</strong><p>
          {% endif %}
          <p class='zzSTDTitle1'>&#xa0;</p>
        OUTPUT
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

      def middle_title_template
        <<~OUTPUT
          <p class='zzSTDTitle1'><strong>{% if doctitleintro %}{{ doctitleintro -}}
          &#x2014; {% endif %}{{ doctitlemain }}{% if doctitlepart %} &#x2014;{% endif %}</strong></p>
          {% if doctitlepart %}<p class='zzSTDTitle1'>&#xa0;</p>
          <p class='zzSTDTitle2'><strong>{% if doctitlepartlabel %}{{ doctitlepartlabel }}: {% endif -%}
          {{ doctitlepart }}</strong><p>
          {% endif %}
          <p class='zzSTDTitle1'>&#xa0;</p>
        OUTPUT
      end

      def ul_label_list(_elem)
        %w(&#x2022; &#x2014; &#x6f;)
      end

      include Init
    end
  end
end
