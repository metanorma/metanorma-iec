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
          #toc += %{<p class="TOCTitle">List of Tables</p>}
          toc += make_TableWordToC(docxml)
        end
        if docxml.at("//p[@class = 'FigureTitle']")
          #toc += %{<p class="TOCTitle">List of Figures</p>}
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
        super
      end

      # Incredibly, the numbered boilerplate list in IEC is NOT A LIST,
      # and it violates numbering conventions for ordered lists (arabic not alpha)
      def word_foreword_cleanup(docxml)
        docxml.xpath("//div[@class = 'boilerplate_legal']//li/p").each_with_index do |l, i|
          l["class"] = "FOREWORD"
          l.children.first.add_previous_sibling(%{#{i+1})<span style="mso-tab-count:1">&#xA0; </span>})
        end
        docxml.xpath("//div[@class = 'boilerplate_legal']//li").each do |l|
          l.replace(l.children)
        end
        b = docxml.at("div[@class = 'boilerplate_legal']")
        b.replace(b.children)
      end

      include BaseConvert
    end
  end
end
