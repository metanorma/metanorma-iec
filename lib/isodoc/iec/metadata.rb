require "isodoc"
require "metanorma-iso"

module IsoDoc
  module Iec
    class  Metadata < IsoDoc::Iso::Metadata
      def docstatus(isoxml, _out)
        docstatus = isoxml.at(ns("//bibdata/status/stage"))
        substage = isoxml.at(ns("//bibdata/status/substage"))
        set(:unpublished, false)
        if docstatus
          set(:stage, docstatus.text)
          set(:stage_int, docstatus.text.to_i)
          set(:unpublished, unpublished(docstatus.text))
          set(:statusabbr, substage["abbreviation"])
          unpublished(docstatus.text) and
            set(:stageabbr, docstatus["abbreviation"])
        end
        revdate = isoxml.at(ns("//version/revision-date"))
        set(:revdate, revdate&.text)
      end

      def unpublished(status)
        status.to_i > 0 && status.to_i < 60
      end
    end
  end
end
