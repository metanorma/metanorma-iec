require "pubid-iec"

module Metanorma
  module Iec
    class Converter < ISO::Converter
      def default_publisher
        "IEC"
      end

      def metadata_stagename(id)
        if @amd
          id.amendments&.first&.stage&.name ||
            id.corrigendums&.first&.stage&.name
        else
          begin
            id.typed_stage_name
          rescue StandardError
            id.stage&.name
          end
        end
      end

      def metadata_status(node, xml)
        x = iso_id_default(iso_id_params(node)).stage
        xml.status do |s|
          s.stage x.harmonized_code.stage, **attr_code(abbreviation: x.abbr)
          s.substage x.harmonized_code.substage
        end
      rescue *STAGE_ERROR
        report_illegal_stage(get_stage(node), get_substage(node))
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

      def base_pubid
        Pubid::Iec::Identifier
      end

      def iso_id_params_core(node)
        pub = iso_id_pub(node)
        ret = { number: node.attr("docnumber"),
                part: node.attr("partnumber"),
                language: node.attr("language")&.split(/,\s*/) || "en",
                type: get_typeabbr(node),
                edition: node.attr("edition"), publisher: pub[0],
                unpublished: /^[0-5]/.match?(get_stage(node)),
                copublisher: pub[1..-1] }
        ret[:copublisher].empty? and ret.delete(:copublisher)
        compact_blank(ret)
      end

      def iso_id_stage(node)
        ret = "#{get_stage(node)}.#{get_substage(node)}"
        if /[A-Z]/.match?(ret) # abbreviation
          ret = get_stage(node)
        end
        ret
      end

      def iso_id_params_resolve(params, params2, node, orig_id)
        ret = super
        params[:number].nil? && !@amd and ret[:number] = "0"
        ret
      end

      def iso_id_out(xml, params, _with_prf)
        params[:stage] == "60.60" and params.delete(:stage)
        super
      end

      def iso_id_out_common(xml, params, _with_prf)
        xml.docidentifier iso_id_default(params).to_s,
                          **attr_code(type: "ISO", primary: "true")
        xml.docidentifier iso_id_reference(params).to_s,
                          **attr_code(type: "iso-reference")
        @id_revdate and
          xml.docidentifier iso_id_revdate(params.merge(year: @id_revdate))
            .to_s(with_edition_month_date: true),
                            **attr_code(type: "iso-revdate")
        xml.docidentifier iso_id_reference(params).urn,
                          **attr_code(type: "URN")
      end

      def iso_id_out_non_amd(xml, params, _with_prf)
        xml.docidentifier iso_id_undated(params).to_s,
                          **attr_code(type: "iso-undated")
        xml.docidentifier iso_id_with_lang(params).to_s,
                          **attr_code(type: "iso-with-lang")
      end

      def iso_id_revdate(params)
        params1 = params.dup.tap { |hs| hs.delete(:unpublished) }
        m = params1[:year].match(/^(\d{4})(-\d{2})?(-\d{2})?/)
        params1[:year] = m[1]
        params1[:month] = m[2].sub(/^-/, "")
        # skipping day for now
        pubid_select(params1).create(**params1)
      end

      def status_abbrev1(node)
        id = iso_id_default({ stage: "60.60" }.merge(iso_id_params(node)))
        id.stage or return ""
        id.stage.abbr
      end

      def get_stage(node)
        stage = node.attr("status") || node.attr("docstage") || "60"
        m = /([0-9])CD$/.match(stage) and node.set_attr("iteration", m[1])
        stage
      end

      def get_substage(node)
        ret = node.attr("docsubstage") and return ret
        st = get_stage(node)
        case st
        when "60" then "60"
        when "30", "40", "50" then "20"
        else "00"
        end
      end

      def iso_id_params_add(node)
        stage = iso_id_stage(node)
        @id_revdate = node.attr("revdate")
        ret = { number: node.attr("amendment-number") ||
          node.attr("corrigendum-number"),
                year: iso_id_year(node) }
        if stage && !cen?(node.attr("publisher"))
          ret[:stage] = stage
        end
        compact_blank(ret)
      end

      def report_illegal_stage(stage, substage)
        out = stage || ""
        /[A-Z]/.match?(out) or out += ".#{substage}"
        err = "Illegal document stage: #{out}"
        @log.add("Document Attributes", nil, err)
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
