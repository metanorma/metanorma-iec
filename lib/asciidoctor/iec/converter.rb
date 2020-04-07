require "asciidoctor"
require "metanorma-iso"

module Asciidoctor
  module Iec
    class Converter < ISO::Converter
      XML_ROOT_TAG = "iec-standard".freeze
      XML_NAMESPACE = "https://www.metanorma.org/ns/iec".freeze

      register_for "iec"

      def init(node)
        super
        @is_iev = node.attr("docnumber") == "60050"
      end

      def metadata_author(node, xml)
        publishers = node.attr("publisher") || "IEC"
        publishers.split(/,[ ]?/).each do |p|
          xml.contributor do |c|
            c.role **{ type: "author" }
            c.organization { |a| organization(a, p) }
          end
        end
      end

      def metadata_publisher(node, xml)
        publishers = node.attr("publisher") || "IEC"
        publishers.split(/,[ ]?/).each do |p|
          xml.contributor do |c|
            c.role **{ type: "publisher" }
            c.organization { |a| organization(a, p) }
          end
        end
      end

      def metadata_copyright(node, xml)
        publishers = node.attr("publisher") || "IEC"
        publishers.split(/,[ ]?/).each do |p|
          xml.copyright do |c|
            c.from (node.attr("copyright-year") || Date.today.year)
            c.owner do |owner|
              owner.organization { |o| organization(o, p) }
            end
          end
        end
      end

      def iso_id(node, xml)
        return unless node.attr("docnumber")
        part, subpart = node&.attr("partnumber")&.split(/-/)
        dn = add_id_parts(node.attr("docnumber"), part, subpart)
        dn = id_stage_prefix(dn, node)
        dn = id_edition_suffix(dn, node)
        xml.docidentifier dn, **attr_code(type: "iso")
      end

      def id_edition_suffix(dn, node)
        ed = node.attr("edition") || 1
        dn += " ED #{ed}"
        dn
      end

      def boilerplate_file(x_orig)
        lang = case x_orig&.at("//bibdata/language")&.text
               when "fr" then "fr"
               else
                 "en"
               end
        File.join(@libdir, "iec_intro_#{lang}.xml")
      end

      def doctype_validate(xmldoc)
        doctype = xmldoc&.at("//bibdata/ext/doctype")&.text
        %w(international-standard technical-specification technical-report 
        publicly-available-specification international-workshop-agreement 
        guide interpretation-sheet).include? doctype or
        @log.add("Document Attributes", nil, "#{doctype} is not a recognised document type")
      end

      def validate(doc)
        content_validate(doc)
        schema_validate(formattedstr_strip(doc.dup),
                        File.join(File.dirname(__FILE__), "iec.rng"))
      end

      STAGE_CODES = {
        "PNW" => "1000",
        "ANW" => "2000",
        "CAN" => "2098",
        "ACD" => "2099",
        "CD" => "3020",
        "BWG" => "3092",
        "A2CD" => "3099",
        "2CD" => "3520",
        "3CD" => "3520",
        "4CD" => "3520",
        "5CD" => "3520",
        "6CD" => "3520",
        "7CD" => "3520",
        "8CD" => "3520",
        "9CD" => "3520",
        "CDM" => "3591",
        "A3CD" => "3592",
        "A4CD" => "3592",
        "A5CD" => "3592",
        "A6CD" => "3592",
        "A7CD" => "3592",
        "A8CD" => "3592",
        "A9CD" => "3592",
        "ACDV" => "3599",
        "CCDV" => "4020",
        "CDVM" => "4091",
        "NCDV" => "4092",
        "NADIS" => "4093",
        "ADIS" => "4099",
        "ADTR" => "4099",
        "ADTS" => "4099",
        "RDISH" => "5000",
        "RFDIS" => "5000",
        "CDISH" => "5020",
        "CDPAS" => "5020",
        "CDTR" => "5020",
        "CDTS" => "5020",
        "CFDIS" => "5020",
        "DTRM" => "5092",
        "DTSM" => "5092",
        "NDTR" => "5092",
        "NDTS" => "5092",
        "NFDIS" => "5092",
        "APUB" => "5099",
        "BPUB" => "6000",
        "PPUB" => "6060",
        "RR" => "9092",
        "AMW" => "9220",
        "WPUB" => "9599",
        "DELPUB" => "9960",
      }.freeze

      DOC_STAGE = {
        "00": "PWI",
        "10": "NWIP",
        "20": "WD",
        "30": "CD",
        "40": "CDV",
        "50": "FDIS",
      }.freeze

      def get_stage(node)
        stage = node.attr("status") || node.attr("docstage") || "60"
        m = /([0-9])CD$/.match(stage) and
          node.set_attr("iteration", m[1])
        STAGE_CODES[stage] and stage = STAGE_CODES[stage][0..1]
        stage
      end

      def get_substage(node)
        st = node.attr("status") || node.attr("docstage")
        stage = get_stage(node)
        node.attr("docsubstage") || 
          ( stage == "60" ? "60" : 
           STAGE_CODES[st] ? STAGE_CODES[st][2..3] :
           "00" )
      end

      def id_stage_abbr(stage, substage, node)
        abbr = DOC_STAGE[stage.to_sym] || ""
        abbr = node.attr("iteration") + abbr if node.attr("iteration")
        abbr
      end

      def load_yaml(lang, script)
        y = if @i18nyaml then YAML.load_file(@i18nyaml)
            elsif lang == "en"
              YAML.load_file(File.join(File.dirname(__FILE__), "i18n-en.yaml"))
            elsif lang == "fr"
              YAML.load_file(File.join(File.dirname(__FILE__), "i18n-fr.yaml"))
            elsif lang == "zh" && script == "Hans"
              YAML.load_file(File.join(File.dirname(__FILE__), "i18n-zh-Hans.yaml"))
            else
              YAML.load_file(File.join(File.dirname(__FILE__), "i18n-en.yaml"))
            end
        super.merge(y)
      end

      def html_converter(node)
        node.nil? ? IsoDoc::Iec::HtmlConvert.new({}) :
          IsoDoc::Iec::HtmlConvert.new(html_extract_attributes(node))
      end

      def doc_converter(node)
        node.nil? ? IsoDoc::Iec::WordConvert.new({}) :
          IsoDoc::Iec::WordConvert.new(doc_extract_attributes(node))
      end
    end
  end
end
