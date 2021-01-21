require "isodoc"
require "metanorma-iso"
require_relative "base_convert"
require_relative "init"

module IsoDoc
  module Iec
    class HtmlConvert < IsoDoc::Iso::HtmlConvert
      def initialize(options)
        super
        @libdir = File.dirname(__FILE__)
      end

      def default_fonts(options)
        {
          bodyfont: (options[:script] == "Hans" ? '"Source Han Sans",serif' : '"Arial",sans-serif'),
        headerfont: (options[:script] == "Hans" ? '"Source Han Sans",sans-serif' : '"Arial",sans-serif'),
        monospacefont: ('"Courier New",monospace'),
        monospacefontsize: "1.0em",
        footnotefontsize: "0.9em",
        }
      end

      def default_file_locations(options)
        @libdir = File.dirname(__FILE__)
        {
          htmlstylesheet: html_doc_path("htmlstyle.scss"),
          htmlcoverpage: html_doc_path("html_iec_titlepage.html"),
          htmlintropage: html_doc_path("html_iec_intro.html"),
          scripts: html_doc_path("scripts.html"),
        }
      end

      def htmlstyle(docxml)
        docxml = super
        b = docxml.at("div[@class = 'boilerplate_legal']/ol")
        b and b["type"] = "1"
        docxml
      end

      def authority_cleanup(docxml)
        auth = docxml.at("//div[@id = 'boilerplate-feedback' or @class = 'boilerplate-feedback']")
        auth&.remove
        super
      end

      include BaseConvert
      include Init
    end
  end
end
