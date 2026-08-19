# frozen_string_literal: true

require "metanorma/standoc"
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

# OCP adoption: register the flavor with the metanorma-document harness.
# The html renderer resolves lazily (require at first render), keeping
# the load graph clean. Re-basing to the Standoc renderer or an own
# renderer later is a change to this registration only.
Metanorma.register_flavor(Metanorma::Flavor.new(
                            name: :iec,
                            model_class: Metanorma::Iec::Document::Root,
                            pubid_module: :"Pubid::Iec",
                            renderers: {
                              html: lambda do |_document, **_options|
                                require "metanorma/iso/html"
                                Metanorma::Iso::Html::Renderer
                              end,
                            },
                          ))
