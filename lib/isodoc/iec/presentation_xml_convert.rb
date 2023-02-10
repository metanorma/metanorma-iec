require_relative "init"
require "isodoc"
require_relative "../../relaton/render-iec/general"

module IsoDoc
  module Iec
    class PresentationXMLConvert < IsoDoc::Iso::PresentationXMLConvert
      def i18n_init(lang, script, i18nyaml = nil)
        super
        @i18n_lg = {}
        @i18n_lg["en"] = I18n.new("en", "Latn", i18nyaml || @i18nyaml)
        @i18n_lg["fr"] = I18n.new("fr", "Latn", i18nyaml || @i18nyaml)
        @i18n_lg["default"] = @i18n
      end

      def clause(docxml)
        docxml.xpath(ns("//clause[not(ancestor::annex)] | " \
                        "//definitions | //references | " \
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
        return unless @is_iev

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
          m << { lang: lg, script: Metanorma::Utils.default_script(lg),
                 designation: l10n_recursive(p.remove, lg).to_xml.strip }
        end
      end

      def l10n_recursive(xml, lang)
        script = Metanorma::Utils.default_script(lang)
        c = HTMLEntities.new
        xml.traverse do |x|
          next unless x.text?

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
        return if pr.empty?

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
                          "#{p.children.to_xml} (#{ref.to_xml})</p>"))
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
          elem << l10n("; #{elem.next_element.remove.children.to_xml}")
        end
        elem.children = l10n("#{@i18n.source}: #{elem.children.to_xml.strip}")
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

      include Init
    end
  end
end
