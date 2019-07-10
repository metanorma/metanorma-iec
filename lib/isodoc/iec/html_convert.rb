require "isodoc"
require "metanorma-iso"

module IsoDoc
  module Iec
    class HtmlConvert < IsoDoc::Iso::HtmlConvert
      def initialize(options)
        super
        @libdir = File.dirname(__FILE__)
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
    end
  end
end
