# frozen_string_literal: true

require "metanorma/standoc"
require "metanorma/iso/document"
# Forward-declare parent namespace so this file is safe to require
# directly (without first requiring metanorma/iec.rb).
module Metanorma
  module Iec
  end
end


module Metanorma
  module Iec::Document
    autoload :Root, "metanorma/iec/document/root"
  end
end


# Backwards-compat alias so external consumers that reference
# Metanorma::IecDocument keep resolving during the transition.
module Metanorma
  existing = defined?(Metanorma::IecDocument) && Metanorma::IecDocument
  if !existing.equal?(Metanorma::Iec::Document)
    Metanorma.send(:remove_const, :IecDocument) if existing
    IecDocument = Metanorma::Iec::Document
  end
end

if defined?(Metanorma::Registers::Setup.setup_iec_register)
  Metanorma::Registers::Setup.setup_iec_register
end

module Metanorma
  deprecate_constant :IecDocument
end

require "metanorma-core"

# OCP adoption: ONE registration in the metanorma-core flavor table
# (metanorma-core#18). Renderer resolves lazily; iso-style today.
Metanorma::Core::Flavors.register(Metanorma::Core::Flavor.new(
  name: :iec,
  gem: "metanorma-iec",
  model_root: Metanorma::Iec::Document::Root,
  pubid_module: :"Pubid::Iec",
  renderers: { html: lambda do |_document, **_options|
    require "metanorma/iso/html"
    Metanorma::Iso::Html::Renderer
  end },
))
