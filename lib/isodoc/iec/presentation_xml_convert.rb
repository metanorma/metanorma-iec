require_relative "init"
require "isodoc"
require_relative "../../relaton/render-iec/general"

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

      def termclause1(elem)
        @is_iev or return clause1(elem)
        @suppressheadingnumbers || elem["unnumbered"] and return
        lbl = @xrefs.anchor(elem["id"], :label, true) or return
        prefix_name(elem, " ", "#{lbl}#{clausedelim}", "title")
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

      def concept(docxml)
        @is_iev and concept_iev(docxml)
        super
      end

      def concept_iev(docxml)
        labels = @xrefs.get_anchors.each_with_object({}) do |(k, v), m|
          m[v[:label]] = k
        end
        docpart = docxml&.at(ns("//bibdata/ext/structuredidentifier/" \
                                "project-number/@part"))&.text or return
        docxml.xpath(ns("//termref[@base = 'IEV']")).each do |t|
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
        @is_iev or return
        docxml.xpath(ns("//term[@language = 'en'][@tag]")).each do |en|
          fr = docxml.at(ns("//term[@language = 'fr'][@tag = '#{en['tag']}']"))
          merge_fr_into_en_term1(en, fr) if fr
        end
        @xrefs.parse_inclusions(clauses: true).parse docxml
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
        @is_iev or return
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
          m << { lang: lg, script: Metanorma::Utils.default_script(lg),
                 designation: to_xml(l10n_recursive(p.remove, lg)).strip }
        end
      end

      def l10n_recursive(xml, lang)
        script = Metanorma::Utils.default_script(lang)
        c = HTMLEntities.new
        xml.traverse do |x|
          x.text? or next
          text = c.encode(c.decode(x.text), :hexadecimal)
          x.replace(cleanup_entities(l10n(text, lang, script), is_xml: false))
        end
        xml
      end

      def merge_otherlang_designations(desgn)
        h = desgn.each_with_object({}) do |e, m|
          if m[e[:lang]]
            m[e[:lang]][:designation] += e[:designation]
          else m[e[:lang]] = e
          end
        end
        h.keys.sort.each_with_object([]) { |k, m| m << h[k] }
      end

      def otherlang_designations1(term, lgs)
        pr = merge_otherlang_designations(
          extract_otherlang_designations(term, lgs),
        )
        pr.empty? and return
        prefs = pr.map do |p|
          "<dt>#{p[:lang]}</dt>" \
            "<dd language='#{p[:lang]}' script='#{p[:script]}'>" \
            "#{cleanup_entities(p[:designation])}</dd>"
        end
        term << "<dl type='other-lang'>#{prefs.join}</dl>"
      end

      def related(docxml)
        docxml.xpath(ns("//term[related]")).each { |f| move_related(f) }
        super
      end

      def move_related(term)
        defn = term.at(ns("./definition")) or return
        term.xpath(ns("./related")).reverse.each do |r|
          defn.next = r.remove
        end
      end

      def related1(node)
        lg = node&.at("./ancestor::xmlns:term/@language")&.text
        @i18n = @i18n_lg[lg] if lg && @i18n_lg[lg]
        p = node.at(ns("./preferred"))
        ref = node.at(ns("./xref | ./eref | ./termref"))
        label = @i18n.relatedterms[node["type"]].upcase
        node.replace(l10n("<p>#{label}: " \
                          "#{to_xml(p.children)} (#{to_xml(ref)})</p>"))
        @i18n = @i18n_lg["default"]
      end

      def termsource_modification(node)
        lg = node&.at("./ancestor::xmlns:term/@language")&.text
        @i18n = @i18n_lg[lg] if lg && @i18n_lg[lg]
        super
        @i18n = @i18n_lg["default"]
      end

      def termsource1(node)
        lg = node&.at("./ancestor::xmlns:term/@language")&.text
        @i18n = @i18n_lg[lg] if lg && @i18n_lg[lg]
        if @is_iev then termsource1_iev(node)
        else super
        end
        @i18n = @i18n_lg["default"]
      end

      def termsource1_iev(elem)
        while elem&.next_element&.name == "termsource"
          elem << "; #{to_xml(elem.next_element.remove.children)}"
        end
        elem.children = l10n("#{@i18n.source}: #{to_xml(elem.children).strip}")
      end

      def termexample(docxml)
        docxml.xpath(ns("//termexample")).each do |f|
          termexample1(f)
        end
      end

      def termexample1(elem)
        lg = elem&.at("./ancestor::xmlns:term/@language")&.text
        @i18n = @i18n_lg[lg] if lg && @i18n_lg[lg]
        example1(elem)
        @i18n = @i18n_lg["default"]
      end

      def termnote1(elem)
        lg = elem&.at("./ancestor::xmlns:term/@language")&.text
        @i18n = @i18n_lg[lg] if lg && @i18n_lg[lg]

        val = @xrefs.anchor(elem["id"], :value) || "???"
        lbl = @i18n.termnote.gsub(/%/, val)
        prefix_name(elem, "", lower2cap(lbl), "name")
        @i18n = @i18n_lg["default"]
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
        title1, title2 = middle_title_parts(nil)
        title2out = ""
        title2 and title2out = <<~OUTPUT
          <p class="zzSTDTitle1">&#xa0;</p>
          <p class="zzSTDTitle2"><strong>#{title2}</strong></p>
        OUTPUT
        ins.next = <<~OUTPUT
          <pagebreak/>
          <p class="zzSTDTitle1">#{@i18n.get['IEC']}</p>
          <p class="zzSTDTitle1">____________</p>
          <p class="zzSTDTitle1">&#xa0;</p>
          <p class="zzSTDTitle1"><strong>#{title1.upcase}</strong></p>#{title2out}
          <p class="zzSTDTitle1">&#xa0;</p>
        OUTPUT
      end

      def middle_title_parts(_out)
        title1 = @meta.get[:doctitlemain]&.sub(/\s+$/, "")
        @meta.get[:doctitleintro] and
          title1 = "#{@meta.get[:doctitleintro]} \u2014 #{title1}"
        title2 = nil
        if @meta.get[:doctitlepart]
          title1 += " \u2014"
          title2 = @meta.get[:doctitlepart]&.sub(/\s+$/, "")
          @meta.get[:doctitlepartlabel] and
            title2 = "#{@meta.get[:doctitlepartlabel]}: #{title2}"
        end
        [title1, title2]
      end

      include Init
    end
  end
end
