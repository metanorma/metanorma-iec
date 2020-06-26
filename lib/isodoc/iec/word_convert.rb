require "isodoc"
require "metanorma-iso"
require_relative "base_convert"

module IsoDoc
  module Iec
    class WordConvert < IsoDoc::Iso::WordConvert
      def initialize(options)
        super
        @libdir = File.dirname(__FILE__)
      end

      def default_fonts(options)
        {
          bodyfont: (options[:script] == "Hans" ? '"SimSun",serif' : '"Arial",sans-serif'),
          headerfont: (options[:script] == "Hans" ? '"SimHei",sans-serif' : '"Arial",sans-serif'),
          monospacefont: '"Courier New",monospace',
        }
      end

      def default_file_locations(options)
        @libdir = File.dirname(__FILE__)
        {
          wordstylesheet: html_doc_path("wordstyle.scss"),
          standardstylesheet: html_doc_path("isodoc.scss"),
          header: html_doc_path("header.html"),
          wordcoverpage: html_doc_path("word_iec_titlepage.html"),
          wordintropage: html_doc_path("word_iec_intro.html"),
          ulstyle: "l22",
          olstyle: "l2",
        }
      end

      def insert_toc(intro, docxml, level)
        toc = ""
        toc += make_WordToC(docxml, level)
        if docxml.at("//p[@class = 'TableTitle']")
          toc += make_TableWordToC(docxml)
        end
        if docxml.at("//p[@class = 'FigureTitle']")
          toc += make_FigureWordToC(docxml)
        end
        intro.sub(/WORDTOC/, toc)
      end

      WORD_TOC_TABLE_PREFACE1 = <<~TOC.freeze
                          <span lang="EN-GB"><span
        style='mso-element:field-begin'></span><span
        style='mso-spacerun:yes'>&#xA0;</span>TOC
        \\h \\z \\t &quot;TableTitle,1&quot; <span
        style='mso-element:field-separator'></span></span>
      TOC

      WORD_TOC_FIGURE_PREFACE1 = <<~TOC.freeze
                                      <span lang="EN-GB"><span
        style='mso-element:field-begin'></span><span
        style='mso-spacerun:yes'>&#xA0;</span>TOC
        \\h \\z \\t &quot;FigureTitle,1&quot; <span
        style='mso-element:field-separator'></span></span>
      TOC

      def make_TableWordToC(docxml)
        toc = ""
        docxml.xpath("//p[@class = 'TableTitle']").each do |h|
          toc += word_toc_entry(1, header_strip(h))
        end
        toc.sub(/(<p class="MsoToc1">)/,
                %{\\1#{WORD_TOC_TABLE_PREFACE1}}) +  WORD_TOC_SUFFIX1
      end

      def make_FigureWordToC(docxml)
        toc = ""
        docxml.xpath("//p[@class = 'FigureTitle']").each do |h|
          toc += word_toc_entry(1, header_strip(h))
        end
        toc.sub(/(<p class="MsoToc1">)/,
                %{\\1#{WORD_TOC_FIGURE_PREFACE1}}) +  WORD_TOC_SUFFIX1
      end

      def header_strip(h)
        h = h.to_s.gsub(/<\/?p[^>]*>/, "")
        super
      end

      def word_cleanup(docxml)
        word_foreword_cleanup(docxml)
        word_table_cleanup(docxml)
        super
      end

      def make_tr_attr(td, row, totalrows, header)
        ret = super
        css_class = (td.name == "th" || header) ? "TABLE-col-heading" : "TABLE-cell"
        ret.merge( "class": css_class )
      end

      def tr_parse(node, out, ord, totalrows, header)
        out.tr do |r|
          node.elements.each do |td|
            attrs = make_tr_attr(td, ord, totalrows - 1, header)
            attrs[:class] = "TABLE-col-heading" if header
            r.send td.name, **attr_code(attrs) do |entry|
              td.children.each { |n| parse(n, entry) }
            end
          end
        end
      end

      def word_table_cleanup(docxml)
        docxml.xpath("//table//*[@class = 'Sourcecode']").each do |p|
          p["class"] = "CODE-TableCell"
        end
        %w(TABLE-col-heading TABLE-cell).each do |style|
          word_table_cleanup1(docxml, style)
        end
      end

      def word_table_cleanup1(docxml, style)
        %w(td th).each do |tdh|
          docxml.xpath("//#{tdh}[@class = '#{style}'][not(descendant::p)]").each do |td|
            p = Nokogiri::XML::Element.new("p", docxml)
            td.children.each { |c| c.parent = p }
            p.parent = td
          end
          docxml.xpath("//#{tdh}[@class = '#{style}']//p").each do |p|
            p["class"] ||= style
          end
        end
      end

      def word_annex_cleanup(docxml)
        super
        non_annex_h1(docxml)
      end

      def non_annex_h1(docxml)
        docxml.xpath("//h1[not(@class)]").each do |h1|
          h1["class"] = "main"
        end
        docxml.xpath("//h1[@class = 'Section3']").each do |h1|
          h1["class"] = "main"
        end
      end

      # Incredibly, the numbered boilerplate list in IEC is NOT A LIST,
      # and it violates numbering conventions for ordered lists 
      # (arabic not alpha)
      BOILERPLATE_PARAS = "//div[@class = 'boilerplate_legal']//li/p".freeze

      def word_foreword_cleanup(docxml)
        docxml.xpath(BOILERPLATE_PARAS).each_with_index do |l, i|
          l["class"] = "FOREWORD"
          l.children.first.add_previous_sibling(
            %{#{i+1})<span style="mso-tab-count:1">&#xA0; </span>})
        end
        docxml.xpath("//div[@class = 'boilerplate_legal']//li").each do |l|
          l.replace(l.children)
        end
        b = docxml.at("div[@class = 'boilerplate_legal']")
        b.replace(b.children)
      end

      def make_body1(body, _docxml)
      end

      def word_cover(docxml)
      end

      def formula_parse1(node, out)
        out.div **attr_code(class: "formula") do |div|
          div.p **attr_code(class: "formula") do |p|
            insert_tab(div, 1)
            parse(node.at(ns("./stem")), div)
            lbl = @xrefs.anchor(node['id'], :label, false)
            unless lbl.nil?
              insert_tab(div, 1)
              div << "(#{lbl})"
            end
          end
        end
      end

      include BaseConvert
    end
  end
end
