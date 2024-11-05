require "isodoc"
require "metanorma-iso"

module IsoDoc
  module Iec
    module BaseConvert
      def boilerplate(node, out)
        # processed in foreword instead
      end

      def foreword(clause, out)
        out.div **attr_code(id: clause["id"]) do |s|
          clause_name(nil, clause.at(ns("./title")), s,
                      { class: "ForewordTitle" })
          clause.elements.each { |e| parse(e, s) unless e.name == "title" }
        end
      end

      def bibliography(node, out)
        @is_iev or return super
      end

      def biblio_list(elem, div, biblio)
        @is_iev or return super
        elem.children.each do |b|
          parse(b, div) unless %w(title bibitem).include? b.name
        end
      end

      def terms_parse(node, out)
        @is_iev or return super
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
