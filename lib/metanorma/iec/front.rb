# pubid-iec merged into the new pubid monogem (github: "pubid/pubid", branch: "main")

module Metanorma
  module Iec
    class Converter < Iso::Converter
      def default_publisher
        "IEC"
      end

      # ── stage resolution ─────────────────────────────────────────────
      #
      # IEC documents name their stage by abbreviation (PNW, ADTS, CDV) or
      # by harmonized code ("10", "40"). Project stages (ADTS, CCDV, …)
      # carry a single harmonized code and their own display name; typed
      # stages (PNW, CDV, DTS) carry a family of codes. Both are needed for
      # metadata; identifier rendering uses the typed-stage abbreviation.

      def iec_project_stages(type_code = nil)
        @iec_project_stages ||= {}
        @iec_project_stages[type_code] ||=
          Pubid::Iec.identifier_types.flat_map do |klass|
            next [] unless klass.const_defined?(:PROJECT_STAGES)
            if type_code && klass.respond_to?(:type) &&
                klass.type[:key].to_s != type_code.to_s
              next []
            end
            klass::PROJECT_STAGES.values
          end
      end

      # Project stages are type-scoped: ADTR is legal for TR but not TS.
      # Returns the stage hash when legal for type_code, nil when not found
      # under that type. A hit under a DIFFERENT type is illegal.
      def iec_find_project_stage(abbr, type_code = nil)
        return nil if abbr.nil?
        hit = iec_project_stages(type_code)
              .find { |s| s[:abbr].to_s.casecmp?(abbr.to_s) }
        return hit if hit || type_code.nil?
        nil
      end

      # Resolve the document's stage token into a hash:
      #   :harmonized  specific "SS.UU" code (e.g. "40.99")
      #   :stage_num   "40"
      #   :substage_num "99"
      #   :abbr        display abbreviation (e.g. "ADTS", "PNW")
      #   :name        display name (e.g. "Approved for DTS")
      #   :typed       Pubid::Components::TypedStage for identifier building
      def iec_resolve_stage(node)
        token = iso_id_stage(node)
        type_code = (get_typeabbr(node) || :is).to_s

        if token && /[A-Z]/.match?(token)
          proj = iec_find_project_stage(token, type_code)
          if proj
            return iec_stage_result(proj[:harmonized_stages].first,
                                    abbr: proj[:abbr], name: proj[:name],
                                    type_code: type_code, project: true)
          end
          ts = iec_locate_typed_stage(token, type_code) ||
            raise(ArgumentError, "Illegal document stage: #{token}")
          return iec_stage_result(ts.harmonized_stages&.first,
                                  abbr: iec_visible_abbr(ts),
                                  name: ts.name,
                                  type_code: type_code, typed: ts)
        end

        code = token
        raise ArgumentError, "Illegal document stage: #{code}" if code.nil? ||
          !/\A\d{2}\.\d{2}\z/.match?(code)

        # Numeric codes resolve through the typed-stage family (CDV, PNW, …),
        # not through project stages: "40.20" is CDV, even though CCDV is a
        # project stage for that code. Project stages apply only when the
        # document names the stage by its project abbreviation.
        ts = Pubid::Iec.all_typed_stages.find do |s|
          s.harmonized_stages&.include?(code) && s.type_code.to_s == type_code
        end
        raise ArgumentError, "Illegal document stage: #{code}" unless ts

        iec_stage_result(code, abbr: iec_visible_abbr(ts), name: ts.name,
                         type_code: type_code, typed: ts)
      end

      def iec_visible_abbr(ts)
        return nil if ts.nil?
        # Canonical abbreviation is the first variant; published IS is ""
        # (rendered without an abbreviation), while CDV/PNW carry their name.
        Array(ts.abbr).first
      end

      # Locate a typed stage by abbreviation. First match the document's own
      # type; then fall back to the generic ("is") stage family, which carries
      # the cross-type abbreviations (PNW, CDV, WD, …). A hit in a DIFFERENT
      # type family (ADTR is TR-only) is not accepted — that stage is illegal
      # for the current document type.
      def iec_locate_typed_stage(token, type_code)
        match = lambda do |tc|
          Pubid::Iec.all_typed_stages.find do |s|
            s.type_code.to_s == tc.to_s &&
              s.abbr.any? { |a| a.to_s.casecmp?(token.to_s) }
          end
        end
        match.call(type_code) || (type_code.to_s == "is" ? nil : match.call("is"))
      end

      def iec_stage_result(code, abbr:, name:, type_code:, typed: nil,
                           project: false)
        num, sub = code.to_s.split(".")
        { harmonized: code, stage_num: num, substage_num: sub,
          abbr: abbr, name: name, type_code: type_code,
          typed: typed, project: project }
      end

      def metadata_stagename(id, info = nil)
        info ||= iec_current_stage_info
        if @amd
          id.amendments&.first&.stage&.name ||
            id.corrigendums&.first&.stage&.name
        else
          iec_stagename_text(info)
        end
      end

      def iec_stagename_text(info)
        return nil unless info
        type_key = info[:type_code].to_s
        type_meta = iec_type_meta(type_key)
        stage_name = info[:name].to_s
        type_name = type_meta[:title].to_s
        if stage_name.empty? || stage_name == type_name
          type_name
        else
          "#{stage_name} #{type_name}"
        end
      end

      def iec_stagename_abbrev(info)
        return nil unless info
        type_meta = iec_type_meta(info[:type_code].to_s)
        type_abbr = (type_meta[:short] || type_meta[:key]).to_s.upcase
        stage_abbr = info[:abbr].to_s
        if stage_abbr.empty?
          type_abbr
        else
          "#{stage_abbr} #{type_abbr}"
        end
      end

      def iec_type_meta(key)
        k = key.to_sym
        { is: { key: :is, title: "International Standard", short: nil },
          ts: { key: :ts, title: "Technical Specification", short: "TS" },
          tr: { key: :tr, title: "Technical Report", short: "TR" },
          pas: { key: :pas, title: "Publicly Available Specification",
                 short: "PAS" },
          guide: { key: :guide, title: "Guide", short: "Guide" },
          dir: { key: :dir, title: "Directive", short: nil },
          wp: { key: :wp, title: "White Paper", short: nil },
          tec: { key: :tec, title: "Technology Report", short: nil },
          sttr: { key: :sttr, title: "Societal and Technology Trend Report",
                  short: nil },
          cs: { key: :cs, title: "Component Specification", short: nil },
          srd: { key: :srd, title: "Systems Reference Document", short: nil },
          od: { key: :od, title: "Operational Document", short: nil },
          ca: { key: :ca, title: "Conformity Assessment", short: nil },
          trf: { key: :trf, title: "Test Report Form", short: nil },
          amd: { key: :amd, title: "Amendment", short: "Amd" },
          cor: { key: :cor, title: "Corrigendum", short: "Cor" },
        }[k] || { key: k, title: k.to_s, short: k.to_s.upcase }
      end

      def iec_current_stage_info
        @iec_current_stage_info
      end

      def metadata_status(node, xml)
        stage = get_stage(node)
        substage = get_substage(node)
        xml.status do |s|
          add_noko_elem(s, "stage", stage,
                        abbreviation: node.attr("docstage-abbrev"))
          add_noko_elem(s, "substage", substage)
        end
      rescue *STAGE_ERROR
        report_illegal_stage(stage, substage)
      end

      def metadata_stage(node, xml)
        info = @iec_current_stage_info || iec_resolve_stage(node)
        @iec_current_stage_info = info
        xml.stagename iec_stagename_text(info)&.strip,
                      **attr_code(abbreviation: iec_stagename_abbrev(info))
      rescue *STAGE_ERROR
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
        Pubid::Iec
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

      def iso_id_out(xml, params)
        params[:stage] == "60.60" and params.delete(:stage)
        super
      end

      def iso_id_out_common(xml, params)
        add_noko_elem(xml, "docidentifier", iso_id_default(params).to_s,
                      type: "ISO", primary: "true")
        add_noko_elem(xml, "docidentifier", iso_id_reference(params).to_s,
                      type: "iso-reference")
        @id_revdate and
          add_noko_elem(xml, "docidentifier",
                        iso_id_revdate_out(params, @id_revdate),
                        type: "iso-revdate")
        add_noko_elem(xml, "docidentifier", iso_id_reference(params).to_urn,
                      type: "URN")
      end

      def iso_id_out_non_amd(xml, params)
        add_noko_elem(xml, "docidentifier", iso_id_undated(params).to_s,
                      type: "iso-undated")
        add_noko_elem(xml, "docidentifier", iso_id_with_lang(params).to_s,
                      type: "iso-with-lang")
      end

      def iso_id_revdate(params)
        params1 = params.dup.tap { |hs| hs.delete(:unpublished) }
        m = params1[:year].match(/^(\d{4})(-\d{2})?(-\d{2})?/)
        params1[:year] = m[1]
        params1[:month] = m[2].sub(/^-/, "")
        # skipping day for now
        pubid_create(params1, lang_form: :none)
      end

      # pubid 2 dropped the with_edition_month_date rendering option; the
      # revdate identifier renders year-month, so the month is spliced into
      # the rendered year (the first 4-digit year after a colon).
      def iso_id_revdate_out(params, revdate)
        str = iso_id_revdate(params.merge(year: revdate)).to_s
        m = revdate.match(/^(\d{4})(-\d{2})?/)
        m[2] and str = str.sub(/:(#{m[1]})/) { ":#{$1}#{m[2]}" }
        str
      end

      def status_abbrev1(node)
        info = iec_resolve_stage(node)
        info[:abbr].to_s
      rescue *STAGE_ERROR
        ""
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
        @log.add("IEC_1", nil, params: [out])
      end

      def metadata_ext(node, xml)
        super
        add_noko_elem(xml, "function", node.attr("function"))
        add_noko_elem(xml, "accessibility_color_inside",
                      node.attr("accessibility-color-inside"))
        add_noko_elem(xml, "cen_processing", node.attr("cen-processing"))
        add_noko_elem(xml, "secretary", node.attr("secretary"))
        add_noko_elem(xml, "interest_to_committees",
                      node.attr("interest-to-committees"))
      end

      # ── pubid 2 construction overrides ───────────────────────────────

      def iso_pubid_registry(_params)
        Pubid::Iec
      end

      def iso_pubid_create(params, lang_form)
        type_code = params[:type].to_s
        type_code = "is" if type_code.empty?
        klass = Pubid::Iec.locate_type(type_code) ||
          Pubid::Iec.locate_type("is")
        klass.new(**iso_pubid_attributes(params, lang_form, type_code))
      end

      def iso_pubid_publisher(params)
        Pubid::Iec::Components::Publisher.new(body: params[:publisher].to_s)
      end

      # Build the typed-stage component for the legacy stage token.
      # Project stages (ADTS, …) and abbreviation tokens are resolved here;
      # the TypedStage is pinned to the SPECIFIC harmonized code so URNs
      # render "stage-40.99" rather than the first of a code family.
      def pubid_typed_stage(stage, type_code)
        return nil if stage.nil?

        stage = "60.00" if stage == :PRF
        info = if stage.to_s.include?(".") || stage.to_s.match?(/\A\d+\z/)
                 iec_stage_result_from_code(stage.to_s, type_code.to_s)
               else
                 iec_resolve_stage_token(stage.to_s, type_code.to_s)
               end
        raise ArgumentError, "Illegal document stage: #{stage}" unless info

        iec_typed_stage_for(info)
      end

      def iec_stage_result_from_code(code, type_code)
        code = "#{code}.00" if code.match?(/\A\d{2}\z/)
        ts = Pubid::Iec.all_typed_stages.find do |s|
          s.harmonized_stages&.include?(code) && s.type_code.to_s == type_code
        end
        return nil unless ts
        iec_stage_result(code, abbr: iec_visible_abbr(ts), name: ts.name,
                         type_code: type_code, typed: ts)
      end

      def iec_resolve_stage_token(token, type_code)
        proj = iec_find_project_stage(token, type_code)
        if proj
          return iec_stage_result(proj[:harmonized_stages].first,
                                  abbr: proj[:abbr], name: proj[:name],
                                  type_code: type_code, project: true)
        end
        ts = iec_locate_typed_stage(token, type_code)
        return nil unless ts
        iec_stage_result(ts.harmonized_stages&.first,
                         abbr: iec_visible_abbr(ts), name: ts.name,
                         type_code: type_code, typed: ts)
      end

      def iec_typed_stage_for(info)
        # Pin the TypedStage to the specific harmonized code so URNs and
        # renderers see the exact stage, not the first of a code family.
        base = info[:typed]
        code_sym = (base&.code || info[:abbr].to_s.downcase.gsub(/\s+/, "_")).to_sym
        stage_sym = (base&.stage_code || :draft).to_sym
        # Published (60.60) must keep stage_code "published" so the URN
        # generator omits the stage token; 60.00 (PRF) must not.
        if info[:harmonized] == "60.60"
          stage_sym = :published
        elsif info[:harmonized] == "60.00"
          stage_sym = :prf
        end
        abbrs = if info[:project]
                  # Project stages render through their generic typed-stage
                  # family (ADTS/40.99 → CDV), matching historical IEC output.
                  # Prefer the IS family as the canonical stage abbreviation,
                  # then prefix the document type for non-IS types ("TS CDV").
                  family = Pubid::Iec.all_typed_stages.find do |s|
                    s.harmonized_stages&.include?(info[:harmonized]) &&
                      s.type_code.to_s == "is"
                  end
                  family ||= Pubid::Iec.all_typed_stages.find do |s|
                    s.harmonized_stages&.include?(info[:harmonized])
                  end
                  stage_abbr = iec_visible_abbr(family) || info[:abbr].to_s
                  type_meta = iec_type_meta(info[:type_code].to_s)
                  type_abbr = (type_meta[:short] || type_meta[:key]).to_s.upcase
                  if info[:type_code].to_s != "is" && !type_abbr.empty?
                    ["#{type_abbr} #{stage_abbr}"]
                  else
                    [stage_abbr]
                  end
                else
                  # Canonical abbr is the first variant; published IS is ""
                  # so the identifier renders without a stage abbreviation.
                  [iec_visible_abbr(base) || info[:abbr].to_s]
                end
        Pubid::Components::TypedStage.new(
          code: code_sym,
          stage_code: stage_sym,
          type_code: info[:type_code].to_s,
          abbr: abbrs,
          name: info[:name].to_s,
          harmonized_stages: [info[:harmonized].to_s],
        )
      end

      # IEC renders language codes long: "(en)", "(el-sq)".
      def iso_id_reference(params)
        params1 = params.dup.tap { |hs| hs.delete(:unpublished) }
        pubid_create(params1, lang_form: :long)
      end

      # IEC uses the long ISO language code and joins multiple codes with "-".
      def pubid_languages(language, lang_form)
        langs = Array(language).flat_map { |l| l.to_s.split(/,\s*/) }
        return [] if langs.empty? || lang_form == :none

        langs.map do |lang|
          original = if lang_form == :short
                       LANG_SINGLE_CHAR[lang] || lang
                     else
                       lang
                     end
          Pubid::Components::Language.new(code: lang, original_code: original)
        end
      end

      def pubid_date(year)
        return nil if year.nil?
        y = year.to_s
        m = y.match(/^(\d{4})(?:-(\d{2}))?(?:-(\d{2}))?/)
        return Pubid::Components::Date.new(year: y.to_i) unless m

        attrs = { year: m[1].to_i }
        attrs[:month] = m[2].to_i if m[2]
        attrs[:day] = m[3].to_i if m[3]
        Pubid::Components::Date.new(**attrs)
      end

      def iso_pubid_attributes(params, lang_form, type_code)
        attrs = super
        if params[:edition]
          attrs[:edition] =
            Pubid::Components::Edition.new(number: params[:edition].to_i)
        end
        attrs
      end
    end
  end
end
