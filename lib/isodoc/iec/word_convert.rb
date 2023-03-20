require "isodoc"
require "metanorma-iso"
require_relative "base_convert"
require_relative "init"

module IsoDoc
  module Iec
    class WordConvert < IsoDoc::Iso::WordConvert
      def initialize(options)
        super
        @libdir = File.dirname(__FILE__)
      end

      def convert(input_filename, file = nil, debug = false,
                output_filename = nil)
      file = File.read(input_filename, encoding: "utf-8") if file.nil?
      @openmathdelim, @closemathdelim = extract_delims(file)
      docxml, filename, dir = convert_init(file, input_filename, debug)
      result = convert1(docxml, filename, dir)
      return result if debug

      output_filename ||= "#{filename}.#{@suffix}"
      postprocess(result, output_filename, dir)
      FileUtils.rm_rf dir
    end

      def font_choice(options)
        if options[:script] == "Hans" then '"Source Han Sans",serif'
        else '"Arial",sans-serif'
        end
      end

      def default_fonts(options)
        {
          bodyfont: font_choice(options),
          headerfont: font_choice(options),
          monospacefont: '"Courier New",monospace',
          normalfontsize: "10.0pt",
          footnotefontsize: "8.0pt",
          smallerfontsize: "8.0pt",
          monospacefontsize: "9.0pt",
        }
      end

      def default_file_locations(_options)
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

      def make_table_word_toc(docxml)
        docxml.at(table_toc_xpath) or return ""
        toc = ""
        docxml.xpath(table_toc_xpath).each do |h|
          toc += word_toc_entry(1, header_strip(h))
        end
        toc.sub(/(<p class="MsoToc1">)/,
                %{\\1#{word_toc_table_preface1}}) + WORD_TOC_SUFFIX1
      end

      def make_figure_word_toc(docxml)
        docxml.at(figure_toc_xpath) or return ""
        toc = ""
        docxml.xpath(figure_toc_xpath).each do |h|
          toc += word_toc_entry(1, header_strip(h))
        end
        toc.sub(/(<p class="MsoToc1">)/,
                %{\\1#{word_toc_figure_preface1}}) + WORD_TOC_SUFFIX1
      end

      def word_toc_preface(level)
        <<~TOC.freeze
          <span lang="EN-GB"><span
            style='mso-element:field-begin'></span><span
            style='mso-spacerun:yes'>&#xA0;</span>TOC
            \\o "1-#{level}" \\h \\z \\u <span
            style='mso-element:field-separator'></span></span>
        TOC
      end

      def header_strip(hdr)
        hdr = hdr.to_s.gsub(/<\/?p[^>]*>/, "")
        super
      end

      def word_cleanup(docxml)
        word_foreword_cleanup(docxml)
        word_table_cleanup(docxml)
        super
      end

      def make_tr_attr(cell, row, totalrows, header, bordered)
        ret = super
        css_class =
          cell.name == "th" || header ? "TABLE-col-heading" : "TABLE-cell"
        ret.merge(class: css_class)
      end

      def tr_parse(node, out, ord, totalrows, header)
        c = node.parent.parent["class"]
        bordered = %w(modspec).include?(c) || !c
        out.tr do |r|
          node.elements.each do |td|
            attrs = make_tr_attr(td, ord, totalrows - 1, header, bordered)
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
          docxml.xpath("//#{tdh}[@class = '#{style}'][not(descendant::p)]")
            .each do |td|
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
            %{#{i + 1})<span style="mso-tab-count:1">&#xA0; </span>},
          )
        end
        docxml.xpath("//div[@class = 'boilerplate_legal']//li").each do |l|
          l.replace(l.children)
        end
        b = docxml.at("div[@class = 'boilerplate_legal']")
        b.replace(b.children)
      end

      def authority_cleanup(docxml)
        auth = docxml.at("//div[@id = 'boilerplate-feedback' or " \
                         "@class = 'boilerplate-feedback']")
        auth&.remove
        super
      end

      def make_body1(body, _docxml); end

      def word_cover(docxml); end

      def style_cleanup(docxml); end

      def bibliography_attrs
        { class: "Section3" }
      end

      def termref_attrs
        {}
      end

      def figure_name_attrs(_node)
        { class: "FigureTitle", style: "text-align:center;" }
      end

      def table_title_attrs(_node)
        { class: "TableTitle", style: "text-align:center;" }
      end

      def para_class(_node)
        classtype = nil
        classtype = "MsoCommentText" if @in_comment
        classtype = "Sourcecode" if @annotation
        classtype
      end

      def annex_name(_annex, name, div)
        preceding_floating_titles(name, div)
        return if name.nil?

        div.h1 class: "Annex" do |t|
          name.children.each { |c2| parse(c2, t) }
          clause_parse_subtitle(name, t)
        end
      end

      def formula_parse1(node, out)
        out.div **attr_code(class: "formula") do |div|
          div.p **attr_code(class: "formula") do |_p|
            insert_tab(div, 1)
            parse(node.at(ns("./stem")), div)
            if lbl = node&.at(ns("./name"))&.text
              insert_tab(div, 1)
              div << "(#{lbl})"
            end
          end
        end
      end

      include BaseConvert
      include Init
    end
  end
end
