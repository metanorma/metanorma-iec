# frozen_string_literal: true

require "metanorma/iso/html"

module Metanorma
  module Iec
    # HTML format slice for the flavor: the renderer, registered with
    # the harness from iec/document.rb. Renders iso-style; the IEC root
    # uses the ISO section classes, which the ISO renderer registers.
    module Html
      autoload :Renderer, "#{__dir__}/html/renderer"
    end
  end
end
