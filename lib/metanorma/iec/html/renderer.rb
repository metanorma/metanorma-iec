# frozen_string_literal: true

module Metanorma
  module Iec
    module Html
      # IEC documents render iso-style; the IEC root uses the ISO
      # section classes the parent renderer already registers — only
      # the root itself needs dispatch (exact-class, OGC pattern).
      class Renderer < Metanorma::Iso::Html::Renderer
        register_render "Metanorma::Iec::Document::Root", :render_document

        # The IEC theme (lib/metanorma/iec/themes/iec) carries the IEC
        # palette, Arial typography and bilingual cover. Documents in Hans
        # script use the IEC converter's Source Han Sans instead. Explicit
        # organization/user themes remain authoritative.
        def resolve_theme
          return super if @theme_override

          theme = Metanorma::Html::Theme.load(:iec)
          if hans_script?
            theme.font_body = '"Source Han Sans", serif'
            theme.font_sans = '"Source Han Sans", sans-serif'
          end
          theme
        end

        private

        def hans_script?
          bibdata = safe_attr(@document, :bibdata)
          Array(safe_attr(bibdata, :script)).any? do |script|
            value = script.respond_to?(:value) ? script.value : script
            Array(value).join == "Hans"
          end
        end
      end
    end
  end
end
