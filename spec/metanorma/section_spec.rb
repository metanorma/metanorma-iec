require "spec_helper"

RSpec.describe Metanorma::Iec do
  before(:all) do
    @blank_hdr = blank_hdr_gen
  end

  it "processes sections" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      .Foreword

      Text

      == Introduction

      === Introduction Subsection

      == Scope

      Text

      == Normative References

      == Terms and Definitions

      === Term1

      == Terms, Definitions, Symbols and Abbreviated Terms

      === Normal Terms

      ==== Term2

      === Symbols and Abbreviated Terms

      == Symbols and Abbreviated Terms

      == Clause 4

      === Introduction

      === Clause 4.2

      == Terms and Definitions

      [appendix]
      == Annex

      === Annex A.1

      [%appendix]
      === Appendix 1

      == Bibliography

      === Bibliography Subsection
    INPUT
    output = <<~OUTPUT
                  #{@blank_hdr}
             <preface><foreword id="_" obligation="informative">
               <title>FOREWORD</title>
               <p id="_">Text</p>
             </foreword><introduction id="_" obligation="informative">
      <title>INTRODUCTION</title><clause id="_" inline-header="false" obligation="informative">
               <title>Introduction Subsection</title>
             </clause>
             </introduction></preface><sections>
             <clause id="_" obligation="normative" type="scope" inline-header='false'>
               <title>Scope</title>
               <p id="_">Text</p>
             </clause>

             <terms id="_" obligation="normative">
               <title>Terms and definitions</title>
               <p id="_">For the purposes of this document, the following terms and definitions apply.</p>
               #{TERMS_BOILERPLATE}
               <term id="term-Term1">
               <preferred><expression><name>Term1</name></expression></preferred>
             </term>
             </terms>
             <clause id="_" obligation="normative"><title>Terms, definitions, symbols and abbreviated terms</title><terms id="_" obligation="normative">
               <title>Normal Terms</title>
               <term id="term-Term2">
               <preferred><expression><name>Term2</name></expression></preferred>
             </term>
             </terms>
             <definitions id="_" obligation="normative"><title>Symbols and abbreviated terms</title></definitions></clause>
             <definitions id="_" obligation="normative"><title>Symbols and abbreviated terms</title></definitions>
             <clause id="_" inline-header="false" obligation="normative"><title>Clause 4</title><clause id="_" inline-header="false" obligation="normative">
               <title>Introduction</title>
             </clause>
             <clause id="_" inline-header="false" obligation="normative">
               <title>Clause 4.2</title>
             </clause></clause>
             <clause id="_" inline-header="false" obligation="normative">
                <title>Terms and Definitions</title>
             </clause>


             </sections><annex id="_" inline-header="false" obligation="normative">
               <title>Annex</title>
               <clause id="_" inline-header="false" obligation="normative">
               <title>Annex A.1</title>
             </clause>
             <appendix id="_" inline-header="false" obligation="normative">
                <title>Appendix 1</title>
             </appendix></annex><bibliography><references id="_" obligation="informative" normative="true">
               <title>Normative references</title><p id="_">There are no normative references in this document.</p>
             </references><clause id="_" obligation="informative">
               <title>Bibliography</title>
               <references id="_" obligation="informative" normative="false">
               <title>Bibliography Subsection</title>
             </references>
             </clause>
             </bibliography>
             </iec-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end

  it "processes sections with title attributes" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      .Foreword

      Text

      [heading=introduction]
      == Εισαγωγή

      === Introduction Subsection

      [heading=scope]
      == Σκοπός

      Text

      [heading=normative references]
      == Κανονιστικές Παραπομπές

      [heading=terms and definitions]
      == Όροι και Ορισμοί

      === Term1

      [heading="terms, definitions, symbols and abbreviated terms"]
      == Όροι, Ορισμοί, Σύμβολα και Συντομογραφίες

      === Normal Terms

      ==== Term2

      [heading=symbols and abbreviated terms]
      === Σύμβολα και Συντομογραφίες

      [heading=symbols and abbreviated terms]
      == Σύμβολα και Συντομογραφίες

      == Clause 4

      === Introduction

      === Clause 4.2

      [appendix]
      == Annex

      === Annex A.1

      [%appendix]
      === Appendx 1

      [heading=bibliography]
      == Βιβλιογραφία

      === Bibliography Subsection
    INPUT
    output = <<~OUTPUT
                  #{@blank_hdr}
             <preface>
             <foreword id="_" obligation="informative">
               <title>FOREWORD</title>
               <p id="_">Text</p>
             </foreword>
             <introduction id="_" obligation="informative">
      <title>INTRODUCTION</title><clause id="_" inline-header="false" obligation="informative">
               <title>Introduction Subsection</title>
             </clause>
             </introduction>
             </preface>
             <sections>
             <clause id="_" obligation="normative" type="scope" inline-header='false'>
               <title>Scope</title>
               <p id="_">Text</p>
             </clause>
             <terms id="_" obligation="normative">
               <title>Terms and definitions</title>
               <p id="_">For the purposes of this document, the following terms and definitions apply.</p>
               #{TERMS_BOILERPLATE}
               <term id="term-Term1">
               <preferred><expression><name>Term1</name></expression></preferred>
             </term>
             </terms>
             <clause id='_' obligation='normative'>
                   <title>Terms, definitions, symbols and abbreviated terms</title>
                   <terms id='_' obligation='normative'>
                     <title>Normal Terms</title>
                     <term id='term-Term2'>
                       <preferred><expression><name>Term2</name></expression></preferred>
                     </term>
                   </terms>
                   <definitions id='_' obligation="normative">
                     <title>Symbols and abbreviated terms</title>
                   </definitions>
                 </clause>
                 <definitions id='_' obligation="normative">
                   <title>Symbols and abbreviated terms</title>
                 </definitions>
                 <clause id='_' inline-header='false' obligation='normative'>
                   <title>Clause 4</title>
                   <clause id='_' inline-header='false' obligation='normative'>
                     <title>Introduction</title>
                   </clause>
                   <clause id='_' inline-header='false' obligation='normative'>
                     <title>Clause 4.2</title>
                   </clause>
                 </clause>
               </sections>
               <annex id='_' inline-header='false' obligation='normative'>
                 <title>Annex</title>
                 <clause id='_' inline-header='false' obligation='normative'>
                   <title>Annex A.1</title>
                 </clause>
                 <appendix id='_' inline-header='false' obligation='normative'>
                   <title>Appendx 1</title>
                 </appendix>
               </annex>
               <bibliography>
                 <references id='_' obligation='informative' normative="true">
                   <title>Normative references</title>
                   <p id="_">There are no normative references in this document.</p>
                 </references>
                 <clause id='_' obligation='informative'>
                   <title>Bibliography</title>
                   <references id='_' obligation='informative' normative="false">
                     <title>Bibliography Subsection</title>
                   </references>
                 </clause>
               </bibliography>
             </iec-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end

  it "processes section obligations" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      [obligation=informative]
      == Clause 1

      === Clause 1a

      [obligation=normative]
      == Clause 2

      [appendix,obligation=informative]
      == Annex
    INPUT
    output = <<~OUTPUT
            #{@blank_hdr}
      <sections><clause id="_" inline-header="false" obligation="informative">
        <title>Clause 1</title>
        <clause id="_" inline-header="false" obligation="informative">
        <title>Clause 1a</title>
      </clause>
      </clause>
      <clause id="_" inline-header="false" obligation="normative">
        <title>Clause 2</title>
      </clause>
      </sections><annex id="_" inline-header="false" obligation="informative">
        <title>Annex</title>
      </annex>
      </iec-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end

  it "processes inline headers" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      == Clause 1

      [%inline-header]
      === Clause 1a

      [appendix]
      == Annex A

      [%inline-header]
      === Clause Aa
    INPUT
    output = <<~OUTPUT
            #{@blank_hdr}
      <sections><clause id="_" inline-header="false" obligation="normative">
        <title>Clause 1</title>
        <clause id="_" inline-header="true" obligation="normative">
        <title>Clause 1a</title>
      </clause>
      </clause>
      </sections><annex id="_" inline-header="false" obligation="normative">
        <title>Annex A</title>
        <clause id="_" inline-header="true" obligation="normative">
        <title>Clause Aa</title>
      </clause>
      </annex>
      </iec-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end

  it "processes blank headers" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
      == Clause 1

      === {blank}

    INPUT
    output = <<~OUTPUT
            #{@blank_hdr}
      <sections>
        <clause id="_" inline-header="false" obligation="normative">
        <title>Clause 1</title>
        <clause id="_" inline-header="false" obligation="normative">
      </clause>
      </clause>
      </sections>
      </iec-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end
end
