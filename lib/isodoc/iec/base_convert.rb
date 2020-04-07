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
        super
      end

      def introduction(isoxml, out)
        return super if !@is_iev
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
      end
    end
  end
end
