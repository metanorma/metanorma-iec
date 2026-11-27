# frozen_string_literal: true

require "ladl"
require "metanorma/iec/sts/profile"

module Metanorma
  module Iec
    # IEC NISO STS through the shared engine (Metanorma::Document::Sts):
    # the ISO/IEC shared 2.1 emitter/reader, parameterized by the IEC
    # publisher profile. The IEC label style profile lives in this gem
    # (canonical home per metanorma#694) and loads through the ladl
    # engine.
    module Sts
      autoload :Profile, "metanorma/iec/sts/profile"

      LABEL_STYLE = File.expand_path("ladl/iec_label_style.lml", __dir__).freeze

      def self.label_profile
        ::Ladl.load_profile(LABEL_STYLE)
      end

      def self.convert(input)
        Metanorma::Document::Sts.convert(input, profile: Profile.instance)
      end

      def self.convert_to_model(input)
        Metanorma::Document::Sts.convert_to_model(input, profile: Profile.instance)
      end

      def self.validate(input)
        Metanorma::Document::Sts.validate(input, profile: Profile.instance)
      end

      def self.render_html(input, **)
        Metanorma::Document::Sts.render_html(input, profile: Profile.instance, **)
      end
    end
  end
end
