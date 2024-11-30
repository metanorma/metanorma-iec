module IsoDoc
  module Iec
    class Xref < IsoDoc::Iso::Xref
      def parse(docxml)
        id = docxml&.at(ns("//bibdata/docnumber"))&.text
        @is_iev = id == "60050"
        id = docxml&.at(ns("//bibdata/docidentifier[@type = 'ISO']"))&.text
        m = /60050-(\d+)/.match(id) and @iev_part = m[1]
        super
      end

      def introduction_names(clause)
        super unless @is_iev
      end

      def initial_anchor_names(docxml)
        super
        return unless @is_iev

        if @parse_settings.empty? || @parse_settings[:clauses]
          @terms_iev_names = true
          terms_iev_names(docxml)
          @terms_iev_names = false
        end
      end

      def terms_iev_names(docxml)
        docxml.xpath(ns("//sections/clause/terms")).each_with_index do |t, i|
          num = semx(t, "#{@iev_part}-%02d" % [i + 1])
          @anchors[t["id"]] =
            { label: num, 
              #xref: l10n("#{@labels['section_iev']} #{num}"),
              xref: labelled_autonum(@labels['section_iev'], num),
              level: 2, type: "clause", elem: @labels["section_iev"] }
          t.xpath(ns("./term")).each_with_index do |c, j|
            num2 = semx(c, "%02d" % [j + 1])
            #section_names1(c, "#{num}#{delim_wrap("-")}#{num2}", 3)
            section_names1(c, num, num2, 3)
          end
        end
      end

      def clausesep
        if @terms_iev_names then "-"
        else super
        end
      end

      def annex_name_lbl(clause, num)
        obl = l10n("(#{@labels['inform_annex']})")
        clause["obligation"] == "normative" and
          obl = l10n("(#{@labels['norm_annex']})")
        obl = "<span class='fmt-obligation'>#{l10n obl}</fmt>"
        s = labelled_autonum(@labels['annex'], num)
        l10n("<strong><span class='fmt-caption-label'>#{s}</span></strong><br/>#{obl}")
      end
    end
  end
end
