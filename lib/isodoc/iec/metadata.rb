require "isodoc"
require "metanorma-iso"
  
module IsoDoc
  module Iec
    class  Metadata < IsoDoc::Iso::Metadata
      STAGE_ABBRS = {
        "00": "PWI",
        "10": "NWIP",
        "20": "WD",
        "30": "CD",
        "40": "CDV",
        "50": "FDIS",
        "60": "IS",
        "90": "(Review)",
        "95": "(Withdrawal)",
      }.freeze
    end
  end
end
