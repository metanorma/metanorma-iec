# frozen_string_literal: true

module Metanorma
  module Iec
    module Html
      # IEC documents render iso-style; the IEC root uses the ISO
      # section classes the parent renderer already registers — only
      # the root itself needs dispatch (exact-class, OGC pattern).
      class Renderer < Metanorma::Iso::Html::Renderer
        register_render "Metanorma::Iec::Document::Root", :render_document

        # Keep the common IEC palette and publisher assets while letting this
        # flavor own its titlepage and the typography used by the IEC HTML
        # converter. Explicit organization/user themes remain authoritative.
        def resolve_theme
          return super if @theme_override

          theme = Metanorma::Html::Theme.load(:iec)
          theme.font_body = hans_script? ? '"Source Han Sans", serif' : '"Arial", sans-serif'
          theme.font_sans = hans_script? ? '"Source Han Sans", sans-serif' : '"Arial", sans-serif'
          theme.font_mono = '"Courier New", monospace'
          theme.font_url = nil

          if theme.respond_to?(:inherited_theme_dirs=)
            theme.inherited_theme_dirs = [theme.theme_dir,
                                          *Array(theme.inherited_theme_dirs)].compact
          end
          theme.theme_dir = File.join(__dir__, "theme")
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
