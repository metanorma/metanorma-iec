require_relative "init"
require "isodoc"

module IsoDoc
  module Iec
    class PresentationXMLConvert < IsoDoc::Iso::PresentationXMLConvert
      include Init
    end
  end
end

