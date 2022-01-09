require "spec_helper"

RSpec.describe Asciidoctor::Iec do
  before(:all) do
    @blank_hdr = blank_hdr_gen
  end

  it "processes open blocks" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      --
      x

      y

      z
      --
    INPUT
    output = <<~OUTPUT
       #{@blank_hdr}
      <sections><p id="_">x</p>
      <p id="_">y</p>
      <p id="_">z</p></sections>
      </iec-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end

  it "processes stem blocks" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      [stem]
      ++++
      r = 1 %
      r = 1 %
      ++++

      [stem]
      ++++
      <mml:math><mml:msub xmlns:mml="http://www.w3.org/1998/Math/MathML" xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math"> <mml:mrow> <mml:mrow> <mml:mi mathvariant="bold-italic">F</mml:mi> </mml:mrow> </mml:mrow> <mml:mrow> <mml:mrow> <mml:mi mathvariant="bold-italic">&#x0391;</mml:mi> </mml:mrow> </mml:mrow> </mml:msub> </mml:math>
      ++++
    INPUT
    output = <<~OUTPUT
           #{@blank_hdr}
      <sections>
        <formula id="_">
        <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><mi>r</mi><mo>=</mo><mn>1</mn><mo>%</mo><mi>r</mi><mo>=</mo><mn>1</mn><mo>%</mo></math></stem>
      </formula>

      <formula id="_">
        <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><msub> <mrow> <mrow> <mi mathvariant="bold-italic">F</mi> </mrow> </mrow> <mrow> <mrow> <mi mathvariant="bold-italic">Α</mi> </mrow> </mrow> </msub> </math></stem>
      </formula>
      </sections>
      </iec-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end

  it "ignores review blocks unless document is in draft mode" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      [[foreword]]
      .Foreword
      Foreword

      [reviewer=ISO,date=20170101,from=foreword,to=foreword]
      ****
      A Foreword shall appear in each document. The generic text is shown here. It does not contain requirements, recommendations or permissions.

      For further information on the Foreword, see *ISO/IEC Directives, Part 2, 2016, Clause 12.*
      ****
    INPUT
    output = <<~OUTPUT
             #{@blank_hdr}
      <sections><p id="foreword">Foreword</p>
      </sections>
      </iec-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end

  it "processes review blocks if document is in draft mode" do
    input = <<~INPUT
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :draft: 1.2
      :no-isobib:

      [[foreword]]
      .Foreword
      Foreword

      [reviewer=ISO,date=20170101,from=foreword,to=foreword]
      ****
      A Foreword shall appear in each document. The generic text is shown here. It does not contain requirements, recommendations or permissions.

      For further information on the Foreword, see *ISO/IEC Directives, Part 2, 2016, Clause 12.*
      ****
    INPUT
    output = <<~OUTPUT
      <sections>
       <p id="foreword">Foreword</p>
       <review reviewer="ISO" id="_" date="20170101T00:00:00Z" from="foreword" to="foreword"><p id="_">A Foreword shall appear in each document. The generic text is shown here. It does not contain requirements, recommendations or permissions.</p>
       <p id="_">For further information on the Foreword, see <strong>ISO/IEC Directives, Part 2, 2016, Clause 12.</strong></p></review></sections>

    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))
      .sub(/^.+<sections>/m, "<sections>")
      .sub(%r{</sections>.*$}m, "</sections>")))
      .to be_equivalent_to xmlpp(output)
  end

  it "processes term notes" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      == Terms and Definitions

      === Term1

      NOTE: This is a note
    INPUT
    output = <<~OUTPUT
             #{@blank_hdr}
      <sections>
        <terms id="_" obligation="normative">
        <title>Terms and definitions</title>
        <p id="_">For the purposes of this document, the following terms and definitions apply.</p>
        #{TERMS_BOILERPLATE}
        <term id="term-term1">
        <preferred><expression><name>Term1</name></expression></preferred>
        <termnote id="_">
        <p id="_">This is a note</p>
      </termnote>
      </term>
      </terms>
      </sections>
      </iec-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end

  it "processes notes" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      NOTE: This is a note
    INPUT
    output = <<~OUTPUT
             #{@blank_hdr}
      <sections>
        <note id="_">
        <p id="_">This is a note</p>
      </note>
      </sections>
      </iec-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end

  it "processes literals" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      ....
      LITERAL
      ....
    INPUT
    output = <<~OUTPUT
            #{@blank_hdr}
      <sections>
        <figure id="_">
        <pre id="_">LITERAL</pre>
      </figure>
      </sections>
      </iec-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end

  it "processes simple admonitions with Asciidoc names" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      CAUTION: Only use paddy or parboiled rice for the determination of husked rice yield.
    INPUT
    output = <<~OUTPUT
      #{@blank_hdr}
       <sections>
         <admonition id="_" type="caution">
         <p id="_">Only use paddy or parboiled rice for the determination of husked rice yield.</p>
       </admonition>
       </sections>
       </iec-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end

  it "processes complex admonitions with non-Asciidoc names" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      [CAUTION,type=Safety Precautions]
      .Safety Precautions
      ====
      While werewolves are hardy community members, keep in mind the following dietary concerns:

      . They are allergic to cinnamon.
      . More than two glasses of orange juice in 24 hours makes them howl in harmony with alarms and sirens.
      . Celery makes them sad.
      ====
    INPUT
    output = <<~OUTPUT
      #{@blank_hdr}
      <sections>
         <admonition id="_" type="safety precautions"><name>Safety Precautions</name><p id="_">While werewolves are hardy community members, keep in mind the following dietary concerns:</p>
       <ol id="_">
         <li>
           <p id="_">They are allergic to cinnamon.</p>
         </li>
         <li>
           <p id="_">More than two glasses of orange juice in 24 hours makes them howl in harmony with alarms and sirens.</p>
         </li>
         <li>
           <p id="_">Celery makes them sad.</p>
         </li>
       </ol></admonition>
       </sections>
       </iec-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end

  it "processes term examples" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      == Terms and Definitions

      === Term1

      [example]
      This is an example
    INPUT
    output = <<~OUTPUT
      #{@blank_hdr}
              <sections>
         <terms id="_" obligation="normative">
         <title>Terms and definitions</title>
         <p id="_">For the purposes of this document, the following terms and definitions apply.</p>
         #{TERMS_BOILERPLATE}
         <term id="term-term1">
         <preferred><expression><name>Term1</name></expression></preferred>
         <termexample id="_">
         <p id="_">This is an example</p>
       </termexample>
       </term>
       </terms>
       </sections>
       </iec-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end

  it "processes examples" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      [example]
      ====
      This is an example

      Amen
      ====
    INPUT
    output = <<~OUTPUT
      #{@blank_hdr}
       <sections>
         <example id="_"><p id="_">This is an example</p>
       <p id="_">Amen</p></example>
       </sections>
       </iec-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end

  it "processes preambles" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      This is a preamble

      == Section 1
    INPUT
    output = <<~OUTPUT
      #{@blank_hdr}
             <preface><foreword id="_" obligation="informative">
         <title>FOREWORD</title>
         <p id="_">This is a preamble</p>
       </foreword></preface><sections>
       <clause id="_" inline-header="false" obligation="normative">
         <title>Section 1</title>
       </clause></sections>
       </iec-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end

  it "processes images" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      .Split-it-right sample divider
      image::spec/examples/rice_images/rice_image1.png[]

    INPUT
    output = <<~OUTPUT
      #{@blank_hdr}
              <sections>
         <figure id="_">
         <name>Split-it-right sample divider</name>
                  <image src="spec/examples/rice_images/rice_image1.png" id="_" mimetype="image/png" height="auto" width="auto"/>
       </figure>
       </sections>
       </iec-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end

  it "accepts width and height attributes on images" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      [height=4,width=3]
      image::spec/examples/rice_images/rice_image1.png[]

    INPUT
    output = <<~OUTPUT
      #{@blank_hdr}
              <sections>
         <figure id="_">
         <image src="spec/examples/rice_images/rice_image1.png" id="_" mimetype="image/png" height="4" width="3"/>
       </figure>
       </sections>
       </iec-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end

  it "accepts auto for width and height attributes on images" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      [height=4,width=auto]
      image::spec/examples/rice_images/rice_image1.png[]

    INPUT
    output = <<~OUTPUT
      #{@blank_hdr}
              <sections>
         <figure id="_">
         <image src="spec/examples/rice_images/rice_image1.png" id="_" mimetype="image/png" height="4" width="auto"/>
       </figure>
       </sections>
       </iec-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end

  it "accepts alignment attribute on paragraphs" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      [align=right]
      This para is right-aligned.
    INPUT
    output = <<~OUTPUT
      #{@blank_hdr}
      <sections>
         <p align="right" id="_">This para is right-aligned.</p>
       </sections>
      </iec-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end

  it "processes blockquotes" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      [quote, ISO, "ISO7301,section 1"]
      ____
      Block quotation
      ____
    INPUT
    output = <<~OUTPUT
      #{@blank_hdr}
       <sections>
         <quote id="_">
         <source type="inline" bibitemid="ISO7301" citeas=""><localityStack><locality type="section"><referenceFrom>1</referenceFrom></locality></localityStack></source>
         <author>ISO</author>
         <p id="_">Block quotation</p>
       </quote>
       </sections>
       </iec-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end

  it "processes source code" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      [source,ruby]
      --
      puts "Hello, world."
      %w{a b c}.each do |x|
        puts x
      end
      --
    INPUT
    output = <<~OUTPUT
      #{@blank_hdr}
       <sections>
         <sourcecode lang="ruby" id="_">puts "Hello, world."
       %w{a b c}.each do |x|
         puts x
       end</sourcecode>
       </sections>
       </iec-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end

  it "processes callouts" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      [source,ruby]
      --
      puts "Hello, world." <1>
      %w{a b c}.each do |x|
        puts x <2>
      end
      --
      <1> This is one callout
      <2> This is another callout
    INPUT
    output = <<~OUTPUT
      #{@blank_hdr}
              <sections><sourcecode lang="ruby" id="_">puts "Hello, world." <callout target="_">1</callout>
       %w{a b c}.each do |x|
         puts x <callout target="_">2</callout>
       end<annotation id="_">
         <p id="_">This is one callout</p>
       </annotation><annotation id="_">
         <p id="_">This is another callout</p>
       </annotation></sourcecode>
       </sections>
       </iec-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end
end
