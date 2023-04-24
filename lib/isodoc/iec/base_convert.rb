require "isodoc"
require "metanorma-iso"

module IsoDoc
  module Iec
    module BaseConvert
      def boilerplate(node, out)
        # processed in foreword instead
      end

      def foreword(sect, out)
        out.div **attr_code(id: sect ? sect["id"] : "") do |s|
          s.h1(class: "ForewordTitle") { |h1| h1 << @i18n.foreword }
          sect&.elements&.each { |e| parse(e, s) unless e.name == "title" }
        end
      end

      def middle_title(_isoxml, out)
        title1, title2 = middle_title_parts(out)
        out.p(class: "zzSTDTitle1") do |p|
          p.b { |b| b << title1 }
        end
        if title2
          out.p(class: "zzSTDTitle1") { |p| p << "&#xa0;" }
          out.p(class: "zzSTDTitle2") do |p|
            p.b { |b| b << title2 }
          end
        end
        out.p(class: "zzSTDTitle1") { |p| p << "&#xa0;" }
      end

      def middle_title_parts(_out)
        title1 = @meta.get[:doctitlemain]&.sub(/\s+$/, "")
        @meta.get[:doctitleintro] and
          title1 = "#{@meta.get[:doctitleintro]} &#x2014; #{title1}"
        title2 = nil
        if @meta.get[:doctitlepart]
          title1 += " &#x2014;"
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
          out.send "h#{depth}", class: "zzSTDTitle2" do |p|
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

      def para_class(node)
        case node["class"]
        when "zzSTDTitle1", "zzSTDTitle2" then "zzSTDTitle1"
        else super
        end
      end

      def clause_attrs(node)
        ret = super
        node["type"] == "boilerplate_legal" and ret["class"] = "boilerplate_legal"
        ret
      end
    end
  end
end
