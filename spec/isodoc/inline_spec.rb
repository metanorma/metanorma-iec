require "spec_helper"

RSpec.describe IsoDoc do
  it "processes inline formatting" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface><foreword>
      <p>
      <em>A</em> <strong>B</strong> <sup>C</sup> <sub>D</sub> <tt>E</tt>
      <strike>F</strike> <smallcap>G</smallcap> <br/> <hr/>
      <bookmark id="H"/> <pagebreak/>
      </p>
      </foreword></preface>
      <sections>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      #{HTML_HDR_BARE}
                 <div>
                   <h1 class="ForewordTitle">FOREWORD</h1>
                   <p>
         <i>A</i> <b>B</b> <sup>C</sup> <sub>D</sub> <tt>E</tt>
         <s>F</s> <span style="font-variant:small-caps;">G</span> <br/> <hr/>
         <a id="H"/> <br/>
         </p>
                 </div>
                 #{IEC_TITLE1}
               </div>
             </body>
         </html>
    OUTPUT
    expect(xmlpp(IsoDoc::Iec::HtmlConvert.new({})
      .convert("test", input, true)))
      .to be_equivalent_to xmlpp(output)
  end

  it "processes links" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface><foreword>
      <p>
      <link target="http://example.com"/>
      <link target="http://example.com">example</link>
      <link target="mailto:fred@example.com"/>
      <link target="mailto:fred@example.com">mailto:fred@example.com</link>
      </p>
      </foreword></preface>
      <sections>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      #{HTML_HDR_BARE}
                 <div>
                   <h1 class="ForewordTitle">FOREWORD</h1>
                   <p>
         <a href="http://example.com">http://example.com</a>
         <a href="http://example.com">example</a>
         <a href="mailto:fred@example.com">fred@example.com</a>
         <a href="mailto:fred@example.com">mailto:fred@example.com</a>
         </p>
                 </div>
                 #{IEC_TITLE1}
               </div>
             </body>
         </html>
    OUTPUT
    expect(xmlpp(IsoDoc::Iec::HtmlConvert.new({})
      .convert("test", input, true)))
      .to be_equivalent_to xmlpp(output)
  end

  it "processes unrecognised markup" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface><foreword>
      <p>
      <barry fred="http://example.com">example</barry>
      </p>
      </foreword></preface>
      <sections>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      #{HTML_HDR_BARE}
                 <div>
                   <h1 class="ForewordTitle">FOREWORD</h1>
                   <p>
         <para><b role="strong">&lt;barry fred="http://example.com"&gt;example&lt;/barry&gt;</b></para>
         </p>
                 </div>
                 #{IEC_TITLE1}
               </div>
             </body>
         </html>
    OUTPUT
    expect(xmlpp(IsoDoc::Iec::HtmlConvert.new({})
      .convert("test", input, true)))
      .to be_equivalent_to xmlpp(output)
  end

  it "overrides AsciiMath delimiters" do
    input = <<~INPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml">
      <preface><foreword>
      <p>
      <stem type="AsciiMath">A</stem>
      (#((Hello))#)
      </p>
      </foreword></preface>
      <sections>
      </iso-standard>
    INPUT
    output = <<~OUTPUT
      #{HTML_HDR_BARE}
                 <div>
                   <h1 class="ForewordTitle">FOREWORD</h1>
                   <p>
         <span class="stem">(#(((A)#)))</span>
         (#((Hello))#)
         </p>
                 </div>
                 #{IEC_TITLE1}
               </div>
             </body>
         </html>
    OUTPUT
    expect(xmlpp(IsoDoc::Iec::HtmlConvert.new({})
      .convert("test", input, true)))
      .to be_equivalent_to xmlpp(output)
  end

  it "processes eref content" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <preface><foreword>
          <p>
          <eref type="inline" bibitemid="IEV" citeas="IEV"><locality type="clause"><referenceFrom>1-2-3</referenceFrom></locality></eref>
          <eref type="inline" bibitemid="ISO712" citeas="ISO 712"/>
          <eref type="inline" bibitemid="ISO712"/>
          <eref type="inline" bibitemid="ISO712"><locality type="table"><referenceFrom>1</referenceFrom></locality></eref>
          <eref type="inline" bibitemid="ISO712"><locality type="table"><referenceFrom>1</referenceFrom><referenceTo>1</referenceTo></locality></eref>
          <eref type="inline" bibitemid="ISO712"><locality type="clause"><referenceFrom>1</referenceFrom></locality><locality type="table"><referenceFrom>1</referenceFrom></locality></eref>
          <eref type="inline" bibitemid="ISO712"><locality type="clause"><referenceFrom>1</referenceFrom></locality><locality type="list"><referenceFrom>a</referenceFrom></locality></eref>
          <eref type="inline" bibitemid="ISO712"><locality type="clause"><referenceFrom>1</referenceFrom></locality></eref>
          <eref type="inline" bibitemid="ISO712"><locality type="clause"><referenceFrom>1.5</referenceFrom></locality></eref>
          <eref type="inline" bibitemid="ISO712"><locality type="table"><referenceFrom>1</referenceFrom></locality>A</eref>
          <eref type="inline" bibitemid="ISO712"><locality type="whole"></locality></eref>
          <eref type="inline" bibitemid="ISO712"><locality type="locality:prelude"><referenceFrom>7</referenceFrom></locality></eref>
          <eref type="inline" bibitemid="ISO712" citeas="ISO 712">A</eref>
          </p>
          </foreword></preface>
          <bibliography><references id="_normative_references" obligation="informative" normative="true"><title>Normative References</title>
      <bibitem id="ISO712" type="standard">
        <title format="text/plain">Cereals and cereal products</title>
        <docidentifier>ISO 712</docidentifier>
        <contributor>
          <role type="publisher"/>
          <organization>
            <abbreviation>ISO</abbreviation>
          </organization>
        </contributor>
      </bibitem>
          </references>
          </bibliography>
          </iso-standard>
    INPUT
    output = <<~OUTPUT
      <foreword displayorder="8">
        <p>
           <eref type="inline" bibitemid="IEV" citeas="IEV"><locality type="clause"><referenceFrom>1-2-3</referenceFrom></locality>IEV, <span class="citesec">1-2-3</span></eref>
           <xref type="inline" target="ISO712">ISO 712</xref>
           <xref type="inline" target="ISO712">ISO 712</xref>
           <xref type="inline" target="ISO712">ISO 712, <span class="citetbl">Table 1</span></xref>
           <xref type="inline" target="ISO712">ISO 712, <span class="citetbl">Table 1–1</span></xref>
           <xref type="inline" target="ISO712">ISO 712, <span class="citesec">Clause 1</span>, <span class="citetbl">Table 1</span></xref>
           <xref type="inline" target="ISO712">ISO 712, <span class="citesec">Clause 1</span> a)</xref>
           <xref type="inline" target="ISO712">ISO 712, <span class="citesec">Clause 1</span></xref>
           <xref type="inline" target="ISO712">ISO 712, <span class="citesec">1.5</span></xref>
           <xref type="inline" target="ISO712">A</xref>
           <xref type="inline" target="ISO712">ISO 712, Whole of text</xref>
           <xref type="inline" target="ISO712">ISO 712, Prelude 7</xref>
           <xref type="inline" target="ISO712">A</xref>
        </p>
      </foreword>
    OUTPUT
    expect(xmlpp(
             Nokogiri::XML(
               IsoDoc::Iec::PresentationXMLConvert.new(presxml_options)
               .convert("test", input, true),
             )
               .at("//xmlns:foreword").to_xml,
           ))
      .to be_equivalent_to xmlpp(output)
  end
end
