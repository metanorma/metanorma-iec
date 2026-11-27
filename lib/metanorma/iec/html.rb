# frozen_string_literal: true

require "metanorma/iso/html"

module Metanorma
  module Iec
    # HTML format slice for the flavor: the renderer, registered with
    # the harness from iec/document.rb. Renders iso-style; the IEC root
    # uses the ISO section classes, which the ISO renderer registers.
    module Html
      # The IEC flavor owns its presentation theme: register it so
      # metanorma-document resolves Theme.load(:iec) to this gem's copy
      # (palette, fonts, element styles and the bilingual cover).
      Metanorma::Html::Theme.register_themes_dir(
        File.expand_path("themes", __dir__),
      )

      autoload :Renderer, "#{__dir__}/html/renderer"
    end
  end
end
