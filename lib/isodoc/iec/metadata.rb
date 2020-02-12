require "isodoc"
require "metanorma-iso"

module IsoDoc
  module Iec
    class  Metadata < IsoDoc::Iso::Metadata
      STAGE_ABBRS = {
        "00" => {"00" => "PWI"},
        "10" => {"00" => "PNW"},
        "20" => {"00" => "ANW", "98" => "CAN", "99" => "ACD"},
        "30" => {"00" => "CD", "20" => "CD", "92" => "BWG", "97" => "MERGED", "98" => "DREJ", "99" => "A2CD"},
        "35" => {"00" => "CD", "20" => "CD", "91" => "CDM", "92" => "ACD", "99" => "ACDV"},
        "40" => {"00" => "CCDV", "20" => "CCDV", "91" => "CDVM", "92" => "NCDV", "93" => "NADIS", "95" => "ADISSB", "99" => "ADIS"},
        "50" => {"00" => "RFDIS", "20" => "CFDIS", "92" => "NFDIS", "95" => "APUBSB", "99" => "APUB"},
        "60" => {"00" => "BPUB", "60" => "PPUB"},
        "90" => {"00" => "RR", "92" => "RR"},
        "92" => {"00" => "AMW", "20" => "AMW"},
        "95" => {"00" => "WPUB", "99" => "WPUB"},
        "99" => {"00" => "DELPUB", "60" => "DELPUB"},
      }.freeze

      def stage_abbrev1(stage, substage, iter, doctype, draft)
        return "" unless stage
        abbr = STAGE_ABBRS.dig(stage, substage) || "??"
        if stage == "35" && substage == "92"
          iter = (iter.to_i + 1) % "02"
        end
        case doctype
        when "technical-report"
          stage = "ADTR" if stage == "40" && substage == "99"
          stage = "CDTR" if stage == "50" && substage == "20"
          stage = "DTRM" if stage == "50" && substage == "92"
        when "technical-specification"
          stage = "ADTS" if stage == "40" && substage == "99"
          stage = "CDTS" if stage == "50" && substage == "20"
          stage = "DTSM" if stage == "50" && substage == "92"
        when "interpretation-sheet"
          stage = "RDISH" if stage == "50" && substage == "00"
          stage = "CDISH" if stage == "50" && substage == "20"
        when "publicly-available-specification"
          stage = "CDPAS" if stage == "50" && substage == "20"
        end
        abbr = abbr.sub(/CD$/, "#{iter}CD") if iter
        abbr
      end

      def docstatus(isoxml, _out)
        docstatus = isoxml.at(ns("//bibdata/status/stage"))
        set(:unpublished, false)
        if docstatus
          set(:stage, docstatus.text)
          set(:stage_int, docstatus.text.to_i)
          set(:unpublished, docstatus.text.to_i > 0 && docstatus.text.to_i < 60)
          abbr = stage_abbrev1(docstatus.text,
                               isoxml&.at(ns("//bibdata/status/substage"))&.text,
                               isoxml&.at(ns("//bibdata/status/iteration"))&.text,
                               isoxml&.at(ns("//bibdata/ext/doctype"))&.text,
                               isoxml&.at(ns("//version/draft"))&.text)
          set(:statusabbr, abbr)
        end
        revdate = isoxml.at(ns("//version/revision-date"))
        set(:revdate, revdate&.text)
      end
    end
  end
end
