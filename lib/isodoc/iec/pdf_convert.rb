require_relative "base_convert"
require "isodoc"

module IsoDoc
  module Iec

    # A {Converter} implementation that generates HTML output, and a document
    # schema encapsulation of the document for validation
    #
    class PdfConvert < IsoDoc::XslfoPdfConvert
      def initialize(options)
        @libdir = File.dirname(__FILE__)
        super
      end

      def pdf_stylesheet(_docxml)
        "iec.international-standard.xsl"
      end
    end
  end
end
