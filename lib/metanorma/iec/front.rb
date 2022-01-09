module Asciidoctor
  module Iec
    class Converter < ISO::Converter
      def metadata_author(node, xml)
        publishers = node.attr("publisher") || "IEC"
        csv_split(publishers)&.each do |p|
          xml.contributor do |c|
            c.role **{ type: "author" }
            c.organization do |a|
              organization(a, p, false, node, !node.attr("publisher"))
            end
          end
        end
      end

      def metadata_publisher(node, xml)
        publishers = node.attr("publisher") || "IEC"
        csv_split(publishers)&.each do |p|
          xml.contributor do |c|
            c.role **{ type: "publisher" }
            c.organization do |a|
              organization(a, p, true, node, !node.attr("publisher"))
            end
          end
        end
      end

      def metadata_copyright(node, xml)
        publishers = node.attr("copyright-holder") || node.attr("publisher") ||
          "IEC"
        csv_split(publishers)&.each do |p|
          xml.copyright do |c|
            c.from (node.attr("copyright-year") || Date.today.year)
            c.owner do |owner|
              owner.organization do |o|
                organization(o, p, true, node, !node.attr("copyright-holder") ||
                             node.attr("publisher"))
              end
            end
          end
        end
      end

      def iso_id(node, xml)
        return unless node.attr("docnumber")

        part, subpart = node&.attr("partnumber")&.split(/-/)
        dn = add_id_parts(node.attr("docnumber"), part, subpart)
        dn = id_stage_prefix(dn, node, false)
        dn = id_edition_suffix(dn, node)
        xml.docidentifier dn, **attr_code(type: "ISO")
      end

      def id_edition_suffix(docnum, node)
        ed = node.attr("edition") || 1
        docnum += " ED #{ed}"
        docnum
      end

      STAGE_CODES = {
        "PNW" => "1000", "ANW" => "2000", "CAN" => "2098", "ACD" => "2099",
        "CD" => "3020", "BWG" => "3092", "A2CD" => "3099", "2CD" => "3520",
        "3CD" => "3520", "4CD" => "3520", "5CD" => "3520", "6CD" => "3520",
        "7CD" => "3520", "8CD" => "3520", "9CD" => "3520", "CDM" => "3591",
        "A3CD" => "3592", "A4CD" => "3592", "A5CD" => "3592", "A6CD" => "3592",
        "A7CD" => "3592", "A8CD" => "3592", "A9CD" => "3592", "ACDV" => "3599",
        "CCDV" => "4020", "CDVM" => "4091", "NCDV" => "4092",
        "NADIS" => "4093", "ADIS" => "4099", "ADTR" => "4099",
        "ADTS" => "4099", "RDISH" => "5000", "RFDIS" => "5000",
        "CDISH" => "5020", "CDPAS" => "5020", "CDTR" => "5020",
        "CDTS" => "5020", "CFDIS" => "5020", "DTRM" => "5092",
        "DTSM" => "5092", "NDTR" => "5092", "NDTS" => "5092",
        "NFDIS" => "5092", "APUB" => "5099", "BPUB" => "6000",
        "PPUB" => "6060", "RR" => "9092", "AMW" => "9220", "WPUB" => "9599",
        "DELPUB" => "9960", "PWI" => "0000", "NWIP" => "1000", "WD" => "2000",
        "CDV" => "4000", "FDIS" => "5000"
      }.freeze

      DOC_STAGE = {
        "00": "PWI",
        "10": "NWIP",
        "20": "WD",
        "30": "CD",
        "40": "CDV",
        "50": "FDIS",
        "60": "PPUB",
        "90": "RR",
        "92": "AMW",
        "95": "WPUB",
        "99": "DELPUB",
      }.freeze

      STAGE_ABBRS = {
        "00" => { "00" => "PWI" },
        "10" => { "00" => "PNW" },
        "20" => { "00" => "ANW", "98" => "CAN", "99" => "ACD" },
        "30" => { "00" => "CD", "20" => "CD", "92" => "BWG", "97" => "MERGED",
                  "98" => "DREJ", "99" => "A2CD" },
        "35" => { "00" => "CD", "20" => "CD", "91" => "CDM", "92" => "ACD",
                  "99" => "ACDV" },
        "40" => { "00" => "CCDV", "20" => "CCDV", "91" => "CDVM",
                  "92" => "NCDV", "93" => "NADIS",
                  "95" => "ADISSB", "99" => "ADIS" },
        "50" => { "00" => "RFDIS", "20" => "CFDIS", "92" => "NFDIS",
                  "95" => "APUBSB", "99" => "APUB" },
        "60" => { "00" => "BPUB", "60" => "PPUB" },
        "90" => { "00" => "RR", "92" => "RR" },
        "92" => { "00" => "AMW", "20" => "AMW" },
        "95" => { "00" => "WPUB", "99" => "WPUB" },
        "99" => { "00" => "DELPUB", "60" => "DELPUB" },
      }.freeze

      STAGE_NAMES = {
        "00": "Preliminary work item",
        "10": "New work item proposal",
        "20": "Working draft",
        "30": "Committee draft",
        "35": "Committee draft",
        "40": "Committed draft for vote",
        "50": "Final draft international standard",
        "60": "International standard",
        "90": "Review",
        "92": "Review",
        "95": "Withdrawal",
        "99": "Deleted",
      }.freeze

      def status_abbrev1(stage, substage, iter, doctype, _draft)
        return "" unless stage

        abbr = STAGE_ABBRS.dig(stage, substage) || "??"
        if stage == "35" && substage == "92"
          iter = (iter.to_i + 1) % "02"
        end
        case doctype
        when "technical-report"
          abbr = "ADTR" if stage == "40" && substage == "99"
          abbr = "CDTR" if stage == "50" && substage == "20"
          abbr = "DTRM" if stage == "50" && substage == "92"
        when "technical-specification"
          abbr = "ADTS" if stage == "40" && substage == "99"
          abbr = "CDTS" if stage == "50" && substage == "20"
          abbr = "DTSM" if stage == "50" && substage == "92"
        when "interpretation-sheet"
          abbr = "RDISH" if stage == "50" && substage == "00"
          abbr = "CDISH" if stage == "50" && substage == "20"
        when "publicly-available-specification"
          abbr = "CDPAS" if stage == "50" && substage == "20"
        end
        abbr = abbr.sub(/CD$/, "#{iter}CD") if iter
        abbr
      end

      def stage_abbr(stage, _substage)
        return "PPUB" if stage == "60"

        DOC_STAGE[stage.to_sym] || "??"
      end

      def stage_name(stage, _substage, _doctype, _iteration)
        STAGE_NAMES[stage.to_sym]
      end

      def get_stage(node)
        stage = node.attr("status") || node.attr("docstage") || "60"
        m = /([0-9])CD$/.match(stage) and node.set_attr("iteration", m[1])
        STAGE_CODES[stage] and stage = STAGE_CODES[stage][0..1]
        stage
      end

      def get_substage(node)
        st = node.attr("status") || node.attr("docstage")
        stage = get_stage(node)
        node.attr("docsubstage") ||
          (if stage == "60"
             "60"
           else
             STAGE_CODES[st] ? STAGE_CODES[st][2..3] : "00"
           end)
      end

      def id_stage_abbr(stage, _substage, node)
        return "" if stage == "60"

        abbr = DOC_STAGE[stage.to_sym] || ""
        abbr = node.attr("iteration") + abbr if node.attr("iteration")
        abbr
      end

      def metadata_status(node, xml)
        stage = get_stage(node)
        substage = get_substage(node)
        xml.status do |s|
          s.stage stage, **attr_code(abbreviation: stage_abbr(stage, substage))
          subst = status_abbrev1(stage, substage, node.attr("iteration"),
                                 doctype(node), node.attr("draft"))
          s.substage substage, **attr_code(abbreviation: subst)
          node.attr("iteration") && (s.iteration node.attr("iteration"))
        end
      end

      def metadata_subdoctype(node, xml)
        super
        a = node.attr("function") and xml.function a
      end

      def metadata_ext(node, xml)
        super
        a = node.attr("accessibility-color-inside") and
          xml.accessibility_color_inside a
        a = node.attr("price-code") and xml.price_code a
        a = node.attr("cen-processing") and xml.cen_processing a
        a = node.attr("secretary") and xml.secretary a
        a = node.attr("interest-to-committees") and xml.interest_to_committees a
      end
    end
  end
end
