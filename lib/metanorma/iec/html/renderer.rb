# frozen_string_literal: true

module Metanorma
  module Iec
    module Html
      # IEC documents render iso-style; the IEC root uses the ISO
      # section classes the parent renderer already registers — only
      # the root itself needs dispatch (exact-class, OGC pattern).
      class Renderer < Metanorma::Iso::Html::Renderer
        register_render "Metanorma::Iec::Document::Root", :render_document
      end
    end
  end
end
