require "isodoc"
require "metanorma-iso"

module IsoDoc
  module Iec
    module BaseConvert
      def metadata_init(lang, script, labels)
        @meta = Metadata.new(lang, script, labels)
      end

      def boilerplate(node, out)
        # processed in foreword instead
      end

      def foreword(isoxml, out)
        f = isoxml.at(ns("//foreword"))
        b = isoxml.at(ns("//boilerplate/legal-statement"))
        page_break(out)
        middle_title(out)
        out.div **attr_code(id: f ? f["id"] : "") do |s|
          s.h1(**{ class: "ForewordTitle" }) { |h1| h1 << @foreword_lbl }
          @meta.get[:doctype] == "Amendment" or
            s.div **attr_code(class: "boilerplate_legal") do |s1|
            b&.elements&.each { |e| parse(e, s1) }
          end
          f&.elements&.each { |e| parse(e, s) unless e.name == "title" }
        end
      end

      def middle_title(out)
        out.p(**{ class: "zzSTDTitle1" }) { |p| p << @labels["IEC"] }
        out.p(**{ class: "zzSTDTitle1" }) { |p| p << "____________" }
        out.p(**{ class: "zzSTDTitle1" }) { |p| p << "&nbsp;" }
        title1 = @meta.get[:doctitlemain]&.sub(/\s+$/, "")
        @meta.get[:doctitleintro] and
          title1 = "#{@meta.get[:doctitleintro]} &mdash; #{title1}"
        if @meta.get[:doctitlepart]
          title1 += " &mdash;"
          title2 = @meta.get[:doctitlepart]&.sub(/\s+$/, "")
          @meta.get[:doctitlepartlabel] and
            title2 = "#{@meta.get[:doctitlepartlabel]}: #{title2}"
        end
        out.p(**{ class: "zzSTDTitle1" }) do |p| 
          p.b { |b| b << title1 }
        end
        if @meta.get[:doctitlepart]
          out.p(**{ class: "zzSTDTitle1" }) { |p| p << "&nbsp;" }
          out.p(**{ class: "zzSTDTitle2" }) do |p| 
            p.b { |b| b << title2 }
          end
        end
        out.p(**{ class: "zzSTDTitle1" }) { |p| p << "&nbsp;" }
      end

      def load_yaml(lang, script)
        y = if @i18nyaml then YAML.load_file(@i18nyaml)
            elsif lang == "en"
              YAML.load_file(File.join(File.dirname(__FILE__), "i18n-en.yaml"))
            elsif lang == "fr"
              YAML.load_file(File.join(File.dirname(__FILE__), "i18n-fr.yaml"))
            elsif lang == "zh" && script == "Hans"
              YAML.load_file(File.join(File.dirname(__FILE__),
                                       "i18n-zh-Hans.yaml"))
            else
              YAML.load_file(File.join(File.dirname(__FILE__), "i18n-en.yaml"))
            end
        super.merge(y)
      end

      def annex_name_lbl(clause, num)
        obl = l10n("(#{@inform_annex_lbl})")
        obl = l10n("(#{@norm_annex_lbl})") if clause["obligation"] == "normative"
        l10n("<b>#{@annex_lbl} #{num}</b><br/><br/>#{obl}")
      end

      def convert1(docxml, filename, dir)
        id = docxml&.at(ns("//bibdata/docnumber"))&.text
        @is_iev = id == "60050"
        id = docxml&.at(ns("//bibdata/docidentifier[@type = 'iso']"))&.text
        m = /60050-(\d+)/.match(id) and @iev_part = m[1]
        super
      end

      def introduction(isoxml, out)
        return super unless @is_iev
        f = isoxml.at(ns("//introduction")) || return
        title_attr = { class: "IntroTitle" }
        page_break(out)
        out.div **{ class: "Section3", id: f["id"] } do |div|
          clause_name(nil, @labels["introduction_iev"], div, title_attr)
          f.elements.each do |e|
            parse(e, div) unless e.name == "title"
          end
        end
      end

      def introduction_names(clause)
        return super unless @is_iev
      end

      def bibliography(isoxml, out)
        return super unless @is_iev
      end

      def biblio_list(f, div, biblio)
        return super unless @is_iev
        i = 0
        f.children.each do |b|
          parse(b, div) unless %w(title bibitem).include? b.name
        end
      end

      def terms_parse(node, out)
        return super unless @is_iev
        page_break(out)
        out.div **attr_code(id: node["id"]) do |div|
          out.p(**{ class: "zzSTDTitle2" }) do |p|
            p.b do |b|
              b << "#{anchor(node['id'], :label)} "
              node&.at(ns("./title"))&.children&.each { |c2| parse(c2, b) }
            end
          end
          node.children.reject { |c1| c1.name == "title" }.each do |c1|
            parse(c1, div)
          end
        end
      end

      def initial_anchor_names(d)
        super
        return unless @is_iev
        terms_iev_names(d)
        middle_section_asset_names(d)
        termnote_anchor_names(d)
        termexample_anchor_names(d)
      end

      def terms_iev_names(d)
        d.xpath(ns("//sections/clause/terms")).each_with_index do |t, i|
          num = "#{@iev_part}-%02d" % [i+1]
          @anchors[t["id"]] =
            { label: num, xref: l10n("#{@labels["section_iev"]}-#{num}"), level: 2,
              type: "clause" }
          t.xpath(ns("./term")).each_with_index do |c, i|
            num2 = "%02d" % [i+1]
            section_names1(c, "#{num}-#{num2}", 3)
          end
        end
      end

      def termref_cleanup(docxml)
        return super unless @is_iev
        docxml.
          gsub(%r{\s*\[/TERMREF\]\s*</p>\s*<p>\s*\[TERMREF\]}, "; ").
          gsub(/\[TERMREF\]\s*/, l10n("#{@source_lbl}: ")).
          gsub(/\s*\[MODIFICATION\]\s*\[\/TERMREF\]/, l10n(", #{@modified_lbl} [/TERMREF]")).
          gsub(/\s*\[\/TERMREF\]\s*/, l10n("")).
          gsub(/\s*\[MODIFICATION\]/, l10n(", #{@modified_lbl} &mdash; "))
      end

      def set_termdomain(termdomain)
        return super unless @is_iev
      end

      def term_suffix(node, out)
        return unless @is_iev
        domain = node&.at(ns("../domain"))&.text
        return unless domain
        out << ", &lt;#{domain}&gt;"
      end

      def deprecated_term_parse(node, out)
        out.p **{ class: "DeprecatedTerms", style:"text-align:left;" } do |p|
          p << l10n("#{@deprecated_lbl}: ")
          node.children.each { |c| parse(c, p) }
          term_suffix(node, p)
        end
      end

      def admitted_term_parse(node, out)
        out.p **{ class: "AltTerms", style:"text-align:left;" } do |p|
          node.children.each { |c| parse(c, p) }
          term_suffix(node, p)
        end
      end

      def term_parse(node, out)
        return super unless @is_iev
        out.p **{ class: "Terms", style:"text-align:left;" } do |p|
          node.children.each { |c| parse(c, p) }
          term_suffix(node, p)
        end
      end
    end
  end
end
