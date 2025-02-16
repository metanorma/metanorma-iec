module IsoDoc
  module Iec
    class PresentationXMLConvert < IsoDoc::Iso::PresentationXMLConvert
      def termclause1(elem)
        @is_iev or return clause1(elem)
        @suppressheadingnumbers || elem["unnumbered"] or
        lbl = @xrefs.anchor(elem["id"], :label, true)
        if lbl
        prefix_name(elem, { caption: " " }, "#{lbl}#{clausedelim}", "title")
        else
        prefix_name(elem, {}, nil, "title")
        end
      end

      def concept(docxml)
        super
        @is_iev and concept_iev(docxml)
      end

      def concept_iev(docxml)
        labels = @xrefs.get_anchors.each_with_object({}) do |(k, v), m|
          v[:label] and m[v[:label].gsub(%r{</?[^>]+>}, "")] = k
        end
        docpart = docxml.at(ns("//bibdata/ext/structuredidentifier/" \
                                "project-number/@part"))&.text or return
        docxml.xpath(ns("//fmt-concept//termref[@base = 'IEV']")).each do |t|
          concept_iev1(t, docpart, labels)
        end
      end

      def concept_iev1(termref, docpart, labels)
        /^#{docpart}-/.match?(termref["target"]) or return
        newtarget = labels[termref["target"]] or return
        termref.name = "fmt-xref"
        termref.delete("base")
        termref["target"] = newtarget
        xref1(termref)
      end

      def terms(docxml)
        otherlang_designations(docxml)
        super
        remove_otherlang_designations(docxml)
        merge_fr_into_en_term(docxml)
      end

      def termdomain(elem, fmt_defn)
        if @is_iev
          #d = elem.at(ns("./domain")) or return
          #d["hidden"] = true
        else super
        end
      end

      def merge_fr_into_en_term(docxml)
        @is_iev or return
        docxml.xpath(ns("//term[@language = 'en'][@tag]")).each do |en|
          fr = docxml.at(ns("//term[@language = 'fr'][@tag = '#{en['tag']}']"))
          merge_fr_into_en_term1(en, fr) if fr
        end
        # renumber
        @xrefs.parse_inclusions(clauses: true).parse docxml
        docxml.xpath(ns("//term/fmt-name | //term/fmt-xref-label")).each(&:remove)
        term(docxml)
      end

      def merge_fr_into_en_term1(en_term, fr_term)
        dl = en_term&.at(ns("./dl[@type = 'other-lang']"))&.remove
        #en_term << fr_term.remove.children
        dup = semx_fmt_dup(fr_term)
        dup.xpath(ns("./fmt-name | ./fmt-xref-label")).each(&:remove)
        en_term << dup
        fr_term.xpath(ns(".//fmt-name | .//fmt-xref-label | " \
          ".//fmt-preferred | .//fmt-admitted | .//fmt-deprecates | " \
          ".//fmt-definition | .//fmt-related | .//fmt-termsource")).each(&:remove)
        fr_term["unnumbered"] = "true"
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

      def remove_otherlang_designations(docxml)
        @is_iev or return
        docxml.xpath(ns("//term")).each do |t|
          remove_otherlang_designations1(t, t["language"]&.split(",") || %w(en fr))
        end
      end

      # KILL
      def extract_otherlang_designations(term, lgs)
        term.xpath(ns(".//preferred/expression[@language]"))
          .each_with_object([]) do |d, m|
          lg = d["language"]
          d.delete("language")
          lgs.include?(lg) and next
          p = d.parent
          designation_annotate(p, p.at(ns("./name")))
          m << { lang: lg, script: Metanorma::Utils.default_script(lg),
                 designation: to_xml(l10n_recursive(p.remove, lg)).strip }
        end
      end

      def extract_otherlang_designations(term, lgs)
        term.xpath(ns(".//preferred/expression[@language]"))
          .each_with_object([]) do |d, m|
            lg = d["language"]
          lgs.include?(lg) and next
          p = semx_fmt_dup(d.parent)
          e = p.at(ns("./expression"))
          e.delete("language")
          designation_annotate(p, p.at(ns(".//name")), d.parent)
          m << { lang: lg, script: Metanorma::Utils.default_script(lg),
                 designation: to_xml(l10n_recursive(p, lg)).strip }
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

      def remove_otherlang_designations1(term, lgs)
        term.xpath(ns(".//fmt-preferred/p/semx[@element = 'preferred']")).each do |s|
          p = semx_orig(s, term)
          lg = p.at(ns("./expression/@language"))&.text or next
          lgs.include?(lg) and next
          s.parent.remove
      end
      end

      def related(docxml)
        #docxml.xpath(ns("//term[related]")).each { |f| move_related(f) }
        super
        docxml.xpath(ns("//term[related]")).each { |f| move_related(f) }
      end

      # KILL
            def move_related(term)
        defn = term.at(ns("./definition")) or return
        term.xpath(ns("./related")).reverse_each do |r|
          defn.next = r.remove
        end
      end

      def move_related(term)
        defn = term.at(ns("./fmt-definition")) or return
        rel = term.at(ns("./fmt-related")) or return
        defn << rel.children
      end

      # KILL
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

            def related1(node)
        lg = node.at("./ancestor::xmlns:term/@language")&.text
        @i18n = @i18n_lg[lg] if lg && @i18n_lg[lg]
        p, ref, orig = related1_prep(node)
      label = @i18n.relatedterms[orig["type"]].upcase
        node.children =(l10n("<p>#{label}: " \
                          "#{to_xml(p)} (#{Common::to_xml(ref)})</p>"))
        @i18n = @i18n_lg["default"]
      end

      def termsource_modification(node)
        lg = node&.at("./ancestor::xmlns:term/@language")&.text
        @i18n = @i18n_lg[lg] if lg && @i18n_lg[lg]
        super
        @i18n = @i18n_lg["default"]
      end

      # KILL
      def termsource1xx(node)
        lg = node&.at("./ancestor::xmlns:term/@language")&.text
        @i18n = @i18n_lg[lg] if lg && @i18n_lg[lg]
        if @is_iev then termsource1_iev(node)
        else super
        end
        @i18n = @i18n_lg["default"]
      end

      # KILL
      def termsource1_iev(elem)
        while elem&.next_element&.name == "termsource"
          elem << "; #{to_xml(elem.next_element.remove.children)}"
        end
        elem.children = l10n("#{@i18n.source}: #{to_xml(elem.children).strip}")
      end

      def termsource_label(elem, sources)
        @is_iev or return super
        lg = elem&.at("./ancestor::xmlns:term/@language")&.text
        @i18n = @i18n_lg[lg] if lg && @i18n_lg[lg]
      elem.replace(l10n("#{@i18n.source}: #{sources}"))
      @i18n = @i18n_lg["default"]
    end

      def termexample(docxml)
        docxml.xpath(ns("//termexample")).each do |f|
          termexample1(f)
        end
      end

      def termexample1(elem)
        lg = elem&.at("./ancestor::xmlns:term/@language")&.text
        #require "debug"; binding.b
        @i18n = @i18n_lg[lg] if lg && @i18n_lg[lg]
        example1(elem)
        @i18n = @i18n_lg["default"]
      end

      def termnote_label(elem)
        lg = elem&.at("./ancestor::xmlns:term/@language")&.text
        @i18n = @i18n_lg[lg] if lg && @i18n_lg[lg]

        val = @xrefs.anchor(elem["id"], :value) || "???"
        lbl = @i18n.termnote.gsub("%", val)
        ret = @i18n.l10n lbl
        @i18n = @i18n_lg["default"]
        ret
      end

      def term1(elem)
        #require 'debug'; binding.b
        super
      end
    end
  end
end
