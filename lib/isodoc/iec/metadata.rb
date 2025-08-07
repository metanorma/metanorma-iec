require "isodoc"
require "metanorma-iso"

module IsoDoc
  module Iec
    class Metadata < IsoDoc::Iso::Metadata
      def docstatus(isoxml, _out)
        docstatus = isoxml.at(ns("//bibdata/status/stage"))
        substage = isoxml.at(ns("//bibdata/status/substage"))
        published = published_default(isoxml)
        if docstatus
          set(:stage, docstatus.text)
          set(:stage_int, docstatus.text.to_i)
          set(:statusabbr, substage["abbreviation"])
          !published and set(:stageabbr, docstatus["abbreviation"])
        end
        revdate = isoxml.at(ns("//bibdata/version/revision-date"))
        set(:revdate, revdate&.text)
      end

      def doctype(xml, _out)
        super
        b = xml.at(ns("//bibdata/ext/doctype#{NOLANG}"))&.text
        b1 = xml.at(ns("//bibdata/ext/doctype[@language = 'en']"))&.text || b
        b1 and set(:doctype_en, status_print(b1))
        b1 = xml.at(ns("//bibdata/ext/doctype[@language = 'fr']"))&.text || b
        b1 and set(:doctype_fr, status_print(b1))
        docfunction(xml)
        dochorizontal(xml)
      end

      def docfunction(xml)
        b = xml.at(ns("//bibdata/ext/function#{NOLANG}"))&.text || return
        b and set(:function, status_print(b))
        b1 = xml.at(ns("//bibdata/ext/function#{currlang}"))&.text || b
        b1 and set(:function_display, status_print(b1))
        b1 = xml.at(ns("//bibdata/ext/function[@language = 'en']"))&.text || b
        b1 and set(:function_en, status_print(b1))
        b1 = xml.at(ns("//bibdata/ext/function[@language = 'fr']"))&.text || b
        b1 and set(:function_fr, status_print(b1))
      end

      def dochorizontal(isoxml)
        b = isoxml&.at(ns("//bibdata/ext/horizontal#{NOLANG}"))&.text || return
        b and set(:horizontal, status_print(b))
        b1 = isoxml&.at(ns("//bibdata/ext/horizontal#{currlang}"))&.text
        b1 and set(:horizontal_display, status_print(b1))
        b1 = isoxml&.at(ns("//bibdata/ext/horizontal[@language = 'en']"))&.text
        b1 and set(:horizontal_en, status_print(b1))
        b1 = isoxml&.at(ns("//bibdata/ext/horizontal[@language = 'fr']"))&.text
        b1 and set(:horizontal_fr, status_print(b1))
      end
    end
  end
end
