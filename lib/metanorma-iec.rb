require "asciidoctor" unless defined? Asciidoctor::Converter
require_relative "asciidoctor/iec/converter"
require_relative "metanorma/iec/version"
require "isodoc/iec/html_convert"
require "isodoc/iec/word_convert"
require "isodoc/iec/pdf_convert"
require "isodoc/iec/presentation_xml_convert"
require "isodoc/iec/metadata"
require "isodoc/iec/xref"

if defined? Metanorma
  require_relative "metanorma/iec"
  Metanorma::Registry.instance.register(Metanorma::Iec::Processor)
end

