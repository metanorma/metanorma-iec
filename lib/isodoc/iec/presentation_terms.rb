module IsoDoc
  module Iec
    class PresentationXMLConvert < IsoDoc::Iso::PresentationXMLConvert
      def termclause1(elem)
        @is_iev or return clause1(elem)
        @suppressheadingnumbers || elem["unnumbered"] and return
        lbl = @xrefs.anchor(elem["id"], :label, true) or return
        prefix_name(elem, " ", "#{lbl}#{clausedelim}", "title")
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

      def termdomain(elem)
        if @is_iev
          d = elem.at(ns("./domain")) or return
          d["hidden"] = true
        else super
        end
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
          otherlang_designations1(t, t["language"]&.split(",") || %w(en fr))
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
        term.xpath(ns("./related")).reverse_each do |r|
          defn.next = r.remove
        end
      end

      def related1(node)
        lg = node.at("./ancestor::xmlns:term/@language")&.text
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

      def termnote_label(elem)
        lg = elem&.at("./ancestor::xmlns:term/@language")&.text
        @i18n = @i18n_lg[lg] if lg && @i18n_lg[lg]

        val = @xrefs.anchor(elem["id"], :value) || "???"
        lbl = @i18n.termnote.gsub("%", val)
        ret = @i18n.l10n "#{lbl}#{termnote_delim(elem)}"
        @i18n = @i18n_lg["default"]
        ret
      end
    end
  end
end
