require "isodoc"
require "metanorma-iso"

module IsoDoc
  module Iec
    module BaseConvert
      def para_class(_node)
        classtype = super
        classtype = "FOREWORD" if @inboilerplate
        classtype
      end

      def foreword(isoxml, out)
        f = isoxml.at(ns("//foreword"))
        b = isoxml.at(ns("//boilerplate/legal-statement"))
        id = f["id"] || ""
        page_break(out)
        out.div **attr_code(id: id) do |s|
          s.h1(**{ class: "ForewordTitle" }) { |h1| h1 << @foreword_lbl }
          @inboilerplate = true
          b&.elements&.each { |e| parse(e, s) }
          @inboilerplate = false
          f&.elements&.each { |e| parse(e, s) unless e.name == "title" }
        end
      end
    end
  end
end
