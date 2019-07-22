require "isodoc"
require "metanorma-iso"

module IsoDoc
  module Iec
    module BaseConvert
      def foreword(isoxml, out)
        f = isoxml.at(ns("//foreword"))
        b = isoxml.at(ns("//boilerplate/legal-statement"))
        id = f ? f["id"] : ""
        page_break(out)
        middle_title(out)
        out.div **attr_code(id: id) do |s|
          s.h1(**{ class: "ForewordTitle" }) { |h1| h1 << @foreword_lbl }
          s.div **attr_code(class: "boilerplate_legal") do |s1|
            b&.elements&.each { |e| parse(e, s1) }
          end
          f&.elements&.each { |e| parse(e, s) unless e.name == "title" }
        end
      end

      def middle_title(out)
        out.p(**{ class: "zzSTDTitle1" }) { |p| p << "INTERNATIONAL ELECTROTECHNICAL COMMISSION" }
        out.p(**{ class: "zzSTDTitle1" }) { |p| p << "____________" }
          out.p(**{ class: "zzSTDTitle1" }) { |p| p << "&nbsp;" }
        title1 = @meta.get[:doctitlemain]&.sub(/\s+$/, "")
        @meta.get[:doctitleintro] and title1 = "#{@meta.get[:doctitleintro]} &mdash; #{title1}"
        if @meta.get[:doctitlepart]
          title1 += " &mdash;"
          title2 = @meta.get[:doctitlepart]&.sub(/\s+$/, "")
          @meta.get[:doctitlepartlabel] and title2 = "#{@meta.get[:doctitlepartlabel]}: #{title2}"
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
    end
  end
end
