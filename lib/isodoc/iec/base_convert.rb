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
        out.div **attr_code(id: id) do |s|
          s.h1(**{ class: "ForewordTitle" }) { |h1| h1 << @foreword_lbl }
          s.div **attr_code(class: "boilerplate_legal") do |s1|
            b&.elements&.each { |e| parse(e, s1) }
          end
          f&.elements&.each { |e| parse(e, s) unless e.name == "title" }
        end
      end
    end
  end
end
