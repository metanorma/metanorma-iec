require_relative "./iec/processor"
require "metanorma/iec/document"
  
module Metanorma
  module Iec

  end
end


# Registry styling: the flavor owns its index theme, registered
# programmatically with the metanorma-document theme system.
begin
  require "metanorma/html"
  Metanorma::Html::Theme.register_themes_dir(
    File.expand_path("iec/themes", __dir__),
  )
rescue LoadError
  # metanorma-document unavailable; registry styling inert
end
