require "relaton-render"
require "isodoc"
require_relative "parse"

module Relaton
  module Render
    module Iec
      class General < ::Relaton::Render::IsoDoc::General
        def config_loc
          YAML.load_file(File.join(File.dirname(__FILE__), "config.yml"))
        end

        def klass_initialize(_options)
          super
          @parseklass = Relaton::Render::Iec::Parse
        end
      end
    end
  end
end