require "isodoc"
require_relative "metadata"
require_relative "xref"

module IsoDoc
  module Iec
    module Init
      def metadata_init(lang, script, labels)
        @meta = Metadata.new(lang, script, labels)
      end

      def xref_init(lang, script, klass, labels, options)
        @xrefs = Xref.new(lang, script, HtmlConvert.new(language: lang, script: script), labels, options)
      end

      def load_yaml(lang, script)
        y = if @i18nyaml then YAML.load_file(@i18nyaml)
            elsif lang == "en"
              YAML.load_file(File.join(File.dirname(__FILE__), "i18n-en.yaml"))
            elsif lang == "fr"
              YAML.load_file(File.join(File.dirname(__FILE__), "i18n-fr.yaml"))
            elsif lang == "zh" && script == "Hans"
              YAML.load_file(File.join(File.dirname(__FILE__),
                                       "i18n-zh-Hans.yaml"))
            else
              YAML.load_file(File.join(File.dirname(__FILE__), "i18n-en.yaml"))
            end
        super.merge(y)
      end

      def convert1(docxml, filename, dir)
        id = docxml&.at(ns("//bibdata/docnumber"))&.text
        @is_iev = id == "60050"
        super
      end
    end
  end
end

