require "pubid-iec"

module Metanorma
  module Iec
    class Converter < ISO::Converter
      def metadata_author(node, xml)
        publishers = node.attr("publisher") || "IEC"
        csv_split(publishers)&.each do |p|
          xml.contributor do |c|
            c.role type: "author"
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
            c.role type: "publisher"
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

      def metadata_stage(id, xml)
        xml.stagename metadata_stagename(id)&.strip,
                      **attr_code(abbreviation: id.stage.abbr&.strip)
      end

      def metadata_stagename(id)
        if @amd
          id.amendments&.first&.stage&.name ||
            id.corrigendums&.first&.stage&.name
        else
          code = id.stage.config.stages["abbreviations"][id.stage.abbr]
          id.stage.config.stages["codes_description"][code]
        end
      end

      def get_typeabbr(node, amd: false)
        node.attr("amendment-number") and return :amd
        node.attr("corrigendum-number") and return :cor
        case doctype(node)
        when "directive" then :dir
        when "white-paper" then :wp
        when "technology-report" then :tec
        when "social-technology-trend-report" then :sttr
        when "component-specification" then :cs
        when "systems-reference-document" then :srd
        when "operational-document" then :od
        when "conformity-assessment" then :ca
        when "test-report-form" then :trf
        when "technical-report" then :tr
        when "technical-specification" then :ts
        when "publicly-available-specification" then :pas
        when "guide" then :guide
        else :is
        end
      end

      def iso_id_params(node)
        params = iso_id_params_core(node)
        params2 = iso_id_params_add(node)
        if node.attr("updates")
          orig_id = Pubid::Iec::Identifier::Base.parse(node.attr("updates"))
          orig_id.edition ||= 1
        end
        iso_id_params_resolve(params, params2, node, orig_id)
      end

      def iso_id_params_core(node)
        pub = (node.attr("publisher") || "IEC").split(/[;,]/)
        ret = { number: node.attr("docnumber"),
                part: node.attr("partnumber"),
                language: node.attr("language")&.split(/,\s*/) || "en",
                type: get_typeabbr(node),
                edition: node.attr("edition"),
                publisher: pub[0],
                unpublished: /^[0-5]/.match?(get_stage(node)),
                copublisher: pub[1..-1] }.compact
        ret[:copublisher].empty? and ret.delete(:copublisher)
        ret
      end

      def iso_id_params_add(node)
        stage = iso_id_stage(node)
        if stage == :"??"
          s = node.attr("status") || node.attr("docstage")
          @fatalerror << "IEC Stage #{s} not recognised"
          @log.add("Metadata", nil, "IEC Stage #{s} not recognised")
          stage = nil
        end
        @id_revdate = node.attr("revdate")
        ret = { number: node.attr("amendment-number") ||
          node.attr("corrigendum-number"),
                year: iso_id_year(node) }.compact
        stage and ret[:stage] = stage
        ret
      end

      def iso_id_params_resolve(params, params2, node, orig_id)
        ret = super
        params[:number].nil? && !@amd and ret[:number] = "0"
        ret
      end

      def iso_id_out(xml, params, _with_prf)
        params[:stage] == "60.60" and params.delete(:stage)
        xml.docidentifier iso_id_default(params).to_s,
                          **attr_code(type: "ISO")
        xml.docidentifier iso_id_reference(params).to_s,
                          **attr_code(type: "iso-reference")
        @id_revdate and
          xml.docidentifier iso_id_revdate(params.merge(year: @id_revdate))
            .to_s(with_edition_month_date: true),
                            **attr_code(type: "iso-revdate")
        xml.docidentifier iso_id_reference(params).urn, **attr_code(type: "URN")
        return if @amd

        xml.docidentifier iso_id_undated(params).to_s,
                          **attr_code(type: "iso-undated")
        xml.docidentifier iso_id_with_lang(params).to_s,
                          **attr_code(type: "iso-with-lang")
      rescue StandardError => e
        clean_abort("Document identifier: #{e}", xml)
      end

      def iso_id_default(params)
        params_nolang = params.dup.tap { |hs| hs.delete(:language) }
        params1 = if params[:unpublished]
                    params_nolang.dup.tap do |hs|
                      hs.delete(:year)
                    end
                  else params_nolang
                  end
        params1.key?(:unpublished) and params1.delete(:unpublished)
        Pubid::Iec::Identifier.create(**params1)
      end

      def iso_id_undated(params)
        params_nolang = params.dup.tap { |hs| hs.delete(:language) }
        params2 = params_nolang.dup.tap do |hs|
          hs.delete(:year)
          hs.delete(:unpublished)
        end
        Pubid::Iec::Identifier.create(**params2)
      end

      def iso_id_with_lang(params)
        params1 = if params[:unpublished]
                    params.dup.tap do |hs|
                      hs.delete(:year)
                    end
                  else params end
        params1.delete(:unpublished)
        Pubid::Iec::Identifier.create(**params1)
      end

      def iso_id_reference(params)
        params1 = params.dup.tap { |hs| hs.delete(:unpublished) }
        Pubid::Iec::Identifier.create(**params1)
      end

      def iso_id_revdate(params)
        params1 = params.dup.tap { |hs| hs.delete(:unpublished) }
        m = params1[:year].match(/^(\d{4})(-\d{2})?(-\d{2})?/)
        params1[:year] = m[1]
        params1[:month] = m[2].sub(/^-/, "")
        # skipping day for now
        Pubid::Iec::Identifier.create(**params1)
      end

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

      def status_abbrev1(node)
        id = iso_id_default({stage: "60.60"}.merge(iso_id_params(node)))
        id.stage or return ""
        id.stage.abbr
      end

      def stage_abbr(stage, _substage, _doctype)
        return "PPUB" if stage == "60"

        DOC_STAGE[stage.to_sym] || nil
      end

      def stage_name(stage, _substage, _doctype, _iteration)
        STAGE_NAMES[stage.to_sym]
      end

      def get_stage(node)
        stage = node.attr("status") || node.attr("docstage") || "60"
        m = /([0-9])CD$/.match(stage) and node.set_attr("iteration", m[1])
        /[A-Z]/.match?(stage) && Pubid::Iec::Identifier.has_stage?(stage) and
          stage = Pubid::Iec::Identifier.parse_stage(stage)
            .harmonized_code.stages.first.sub(/\.\d\d$/, "")
        stage
      end

      def get_substage(node)
        ret = node.attr("docsubstage") and return ret
        st = node.attr("status") || node.attr("docstage")
        (if get_stage(node) == "60"
           "60"
         elsif /[A-Z]/.match?(st) && Pubid::Iec::Identifier.has_stage?(st)
           Pubid::Iec::Identifier.parse_stage(st)
             .harmonized_code.stages.first.sub(/^\d\d\./, "")
         else
           "00"
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
          s.stage stage,
                  **attr_code(abbreviation: stage_abbr(stage, substage, nil))
          subst = status_abbrev1(node)
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

      def metadata_approval_committee(node, xml); end
    end
  end
end
