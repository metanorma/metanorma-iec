require "isodoc"
require "metanorma-iso"

module IsoDoc
  module Iec
    module BaseConvert
      def boilerplate(node, out)
        # processed in foreword instead
      end

      def foreword(isoxml, out)
        f = isoxml.at(ns("//foreword"))
        b = isoxml.at(ns("//boilerplate/legal-statement"))
        page_break(out)
        iec_orgname(out)
        middle_title(isoxml, out)
        foreword1(f, b, out)
      end

      def foreword1(sect, boilerplate, out)
        out.div **attr_code(id: sect ? sect["id"] : "") do |s|
          s.h1(**{ class: "ForewordTitle" }) { |h1| h1 << @i18n.foreword }
          @meta.get[:doctype] == "Amendment" or
            s.div **attr_code(class: "boilerplate_legal") do |s1|
              boilerplate&.elements&.each { |e| parse(e, s1) }
            end
          sect&.elements&.each { |e| parse(e, s) unless e.name == "title" }
        end
      end

      def iec_orgname(out)
        out.p(**{ class: "zzSTDTitle1" }) { |p| p << @i18n.get["IEC"] }
        out.p(**{ class: "zzSTDTitle1" }) { |p| p << "____________" }
        out.p(**{ class: "zzSTDTitle1" }) { |p| p << "&nbsp;" }
      end

      def middle_title(_isoxml, out)
        title1, title2 = middle_title_parts(out)
        out.p(**{ class: "zzSTDTitle1" }) do |p|
          p.b { |b| b << title1 }
        end
        if title2
          out.p(**{ class: "zzSTDTitle1" }) { |p| p << "&nbsp;" }
          out.p(**{ class: "zzSTDTitle2" }) do |p|
            p.b { |b| b << title2 }
          end
        end
        out.p(**{ class: "zzSTDTitle1" }) { |p| p << "&nbsp;" }
      end

      def middle_title_parts(_out)
        title1 = @meta.get[:doctitlemain]&.sub(/\s+$/, "")
        @meta.get[:doctitleintro] and
          title1 = "#{@meta.get[:doctitleintro]} &mdash; #{title1}"
        title2 = nil
        if @meta.get[:doctitlepart]
          title1 += " &mdash;"
          title2 = @meta.get[:doctitlepart]&.sub(/\s+$/, "")
          @meta.get[:doctitlepartlabel] and
            title2 = "#{@meta.get[:doctitlepartlabel]}: #{title2}"
        end
        [title1, title2]
      end

      def bibliography(isoxml, out)
        return super unless @is_iev
      end

      def biblio_list(elem, div, biblio)
        return super unless @is_iev

        elem.children.each do |b|
          parse(b, div) unless %w(title bibitem).include? b.name
        end
      end

      def terms_parse(node, out)
        return super unless @is_iev

        page_break(out)
        out.div **attr_code(id: node["id"]) do |div|
          depth = clause_title_depth(node, nil)
          out.send "h#{depth}", **{ class: "zzSTDTitle2" } do |p|
            p.b do |b|
              node&.at(ns("./title"))&.children&.each { |c2| parse(c2, b) }
            end
          end
          node.children.reject { |c1| c1.name == "title" }.each do |c1|
            parse(c1, div)
          end
        end
      end

      def set_termdomain(termdomain)
        return super unless @is_iev
      end
    end
  end
end
