require "spec_helper"

RSpec.describe IsoDoc::Iec do
  it "processes IsoXML bibliographies" do
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata>
          <language>en</language>
          </bibdata>
          <preface><foreword>
        <p id="_f06fd0d1-a203-4f3d-a515-0bdba0f8d83f">
        <eref bibitemid="ISO712"/>
        <eref bibitemid="ISBN"/>
        <eref bibitemid="ISSN"/>
        <eref bibitemid="ISO16634"/>
        <eref bibitemid="ref1"/>
        <eref bibitemid="ref10"/>
        <eref bibitemid="ref12"/>
        <eref bibitemid="zip_ffs"/>
        </p>
          </foreword></preface>
          <bibliography><references id="_normative_references" obligation="informative" normative="true"><title>Normative References</title>
          <p>The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
      <bibitem id="ISO712" type="standard">
        <title format="text/plain">Cereals or cereal products</title>
        <title type="main" format="text/plain">Cereals and cereal products</title>
        <docidentifier type="ISO">ISO 712</docidentifier>
        <docidentifier type="metanorma">[110]</docidentifier>
        <contributor>
          <role type="publisher"/>
          <organization>
            <name>International Organization for Standardization</name>
          </organization>
        </contributor>
      </bibitem>
      <bibitem id="ISO16634" type="standard">
        <title language="x" format="text/plain">Cereals, pulses, milled cereal products, xxxx, oilseeds and animal feeding stuffs</title>
        <title language="en" format="text/plain">Cereals, pulses, milled cereal products, oilseeds and animal feeding stuffs</title>
        <docidentifier type="ISO">ISO 16634:-- (all parts)</docidentifier>
        <date type="published"><on>--</on></date>
        <contributor>
          <role type="publisher"/>
          <organization>
            <abbreviation>ISO</abbreviation>
          </organization>
        </contributor>
        <note format="text/plain" reference="1" type="Unpublished-Status">Under preparation. (Stage at the time of publication ISO/DIS 16634)</note>
        <extent type="part">
        <referenceFrom>all</referenceFrom>
        </extent>

      </bibitem>
      <bibitem id="ISO20483" type="standard">
        <title format="text/plain">Cereals and pulses</title>
        <docidentifier type="ISO">ISO 20483:2013-2014</docidentifier>
        <date type="published"><from>2013</from><to>2014</to></date>
        <contributor>
          <role type="publisher"/>
          <organization>
            <name>International Organization for Standardization</name>
          </organization>
        </contributor>
      </bibitem>
      <bibitem id="ref1">
        <formattedref format="application/x-isodoc+xml"><smallcap>Standard No I.C.C 167</smallcap>. <em>Determination of the protein content in cereal and cereal products for food and animal feeding stuffs according to the Dumas combustion method</em> (see <link target="http://www.icc.or.at"/>)</formattedref>
        <docidentifier type="ICC">167</docidentifier>
      </bibitem>
      <note><p>This is an annotation of ISO 20483:2013-2014</p></note>
          <bibitem id="zip_ffs"><formattedref format="application/x-isodoc+xml">Title 5</formattedref><docidentifier type="metanorma">[5]</docidentifier></bibitem>


      </references><references id="_bibliography" obligation="informative" normative="false">
        <title>Bibliography</title>
      <bibitem id="ISBN" type="book">
        <title format="text/plain">Chemicals for analytical laboratory use</title>
        <docidentifier type="ISBN">ISBN</docidentifier>
        <docidentifier type="metanorma">[1]</docidentifier>
        <contributor>
          <role type="publisher"/>
          <organization>
            <abbreviation>ISBN</abbreviation>
          </organization>
        </contributor>
      </bibitem>
      <bibitem id="ISSN" type="journal">
        <title format="text/plain">Instruments for analytical laboratory use</title>
        <docidentifier type="ISSN">ISSN</docidentifier>
        <docidentifier type="metanorma">[2]</docidentifier>
        <contributor>
          <role type="publisher"/>
          <organization>
            <abbreviation>ISSN</abbreviation>
          </organization>
        </contributor>
      </bibitem>
      <note><p>This is an annotation of document ISSN.</p></note>
      <note><p>This is another annotation of document ISSN.</p></note>
      <bibitem id="ISO3696" type="standard">
        <title format="text/plain">Water for analytical laboratory use</title>
        <docidentifier type="ISO">ISO 3696</docidentifier>
        <contributor>
          <role type="publisher"/>
          <organization>
            <abbreviation>ISO</abbreviation>
          </organization>
        </contributor>
      </bibitem>
      <bibitem id="ref10">
        <formattedref format="application/x-isodoc+xml"><smallcap>Standard No I.C.C 167</smallcap>. <em>Determination of the protein content in cereal and cereal products for food and animal feeding stuffs according to the Dumas combustion method</em> (see <link target="http://www.icc.or.at"/>)</formattedref>
        <docidentifier type="metanorma">[10]</docidentifier>
      </bibitem>
      <bibitem id="ref11">
        <title>Internet Calendaring and Scheduling Core Object Specification (iCalendar)</title>
        <docidentifier type="IETF">RFC 10</docidentifier>
      </bibitem>
      <bibitem id="ref12" type="standard">
        <formattedref format="application/x-isodoc+xml">CitationWorks. 2019. <em>How to cite a reference</em>.</formattedref>
        <docidentifier type="metanorma">[Citn]</docidentifier>
        <docidentifier type="IETF">RFC 20</docidentifier>
      </bibitem>


      </references>
      </bibliography>
          </iso-standard>
    INPUT

    presxml = <<~OUTPUT
      <iso-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
              <bibdata>
              <language current="true">en</language>
              </bibdata>
              #{PREFACE}
            <foreword id="_" displayorder="8">
                <title id="_">FOREWORD</title>
                <fmt-title depth="1">
                   <semx element="title" source="_">FOREWORD</semx>
                </fmt-title>
                <p id="_">
                   <eref bibitemid="ISO712" id="_"/>
                   <semx element="eref" source="_">
                      <fmt-xref target="ISO712">ISO 712</fmt-xref>
                   </semx>
                   <eref bibitemid="ISBN" id="_"/>
                   <semx element="eref" source="_">
                      <fmt-xref target="ISBN">[3]</fmt-xref>
                   </semx>
                   <eref bibitemid="ISSN" id="_"/>
                   <semx element="eref" source="_">
                      <fmt-xref target="ISSN">[4]</fmt-xref>
                   </semx>
                   <eref bibitemid="ISO16634" id="_"/>
                   <semx element="eref" source="_">
                      <fmt-xref target="ISO16634">ISO 16634:-- (all parts)</fmt-xref>
                   </semx>
                   <eref bibitemid="ref1" id="_"/>
                   <semx element="eref" source="_">
                      <fmt-xref target="ref1">ICC 167</fmt-xref>
                   </semx>
                   <eref bibitemid="ref10" id="_"/>
                   <semx element="eref" source="_">
                      <fmt-xref target="ref10">[6]</fmt-xref>
                   </semx>
                   <eref bibitemid="ref12" id="_"/>
                   <semx element="eref" source="_">
                      <fmt-xref target="ref12">Citn</fmt-xref>
                   </semx>
                   <eref bibitemid="zip_ffs" id="_"/>
                   <semx element="eref" source="_">
                      <fmt-xref target="zip_ffs">[2]</fmt-xref>
                   </semx>
                </p>
             </foreword>
          </preface>
          <sections>
             <references id="_" obligation="informative" normative="true" displayorder="9">
                <title id="_">Normative References</title>
                <fmt-title depth="1">
                   <span class="fmt-caption-label">
                      <semx element="autonum" source="_">1</semx>
                   </span>
                   <span class="fmt-caption-delim">
                      <tab/>
                   </span>
                   <semx element="title" source="_">Normative References</semx>
                </fmt-title>
                <fmt-xref-label>
                   <span class="fmt-element-name">Clause</span>
                   <semx element="autonum" source="_">1</semx>
                </fmt-xref-label>
                <p>The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
                <bibitem id="ISO712" type="standard">
                   <formattedref>
                      <em>
                         <span class="stddocTitle">Cereals and cereal products</span>
                      </em>
                   </formattedref>
                   <docidentifier type="metanorma-ordinal">[1]</docidentifier>
                   <docidentifier type="ISO">ISO 712</docidentifier>
                   <docidentifier scope="biblio-tag">ISO 712</docidentifier>
                   <biblio-tag>[1], ISO 712, </biblio-tag>
                </bibitem>
                <bibitem id="ISO16634" type="standard">
                   <formattedref>
                      <em>
                         <span class="stddocTitle">Cereals, pulses, milled cereal products, oilseeds and animal feeding stuffs</span>
                      </em>
                      .
                   </formattedref>
                   <docidentifier type="ISO">ISO 16634:-- (all parts)</docidentifier>
                   <docidentifier scope="biblio-tag">ISO 16634:-- (all parts)</docidentifier>
                   <note format="text/plain" reference="1" type="Unpublished-Status">Under preparation. (Stage at the time of publication ISO/DIS 16634)</note>
                   <biblio-tag>
                      ISO 16634:-- (all parts)
                      <fn reference="1">
                         <p>Under preparation. (Stage at the time of publication ISO/DIS 16634)</p>
                      </fn>
                      ,
                   </biblio-tag>
                </bibitem>
                <bibitem id="ISO20483" type="standard">
                   <formattedref>
                      <em>
                         <span class="stddocTitle">Cereals and pulses</span>
                      </em>
                   </formattedref>
                   <docidentifier type="ISO">ISO 20483:2013-2014</docidentifier>
                   <docidentifier scope="biblio-tag">ISO 20483:2013-2014</docidentifier>
                   <biblio-tag>ISO 20483:2013-2014, </biblio-tag>
                </bibitem>
                <bibitem id="ref1">
                   <formattedref format="application/x-isodoc+xml">
                      <smallcap>Standard No I.C.C 167</smallcap>
                      .
                      <em>Determination of the protein content in cereal and cereal products for food and animal feeding stuffs according to the Dumas combustion method</em>
                      (see
                      <link target="http://www.icc.or.at" id="_"/>
                      <semx element="link" source="_">
                         <fmt-link target="http://www.icc.or.at"/>
                      </semx>
                      )
                   </formattedref>
                   <docidentifier type="ICC">ICC 167</docidentifier>
                   <docidentifier scope="biblio-tag">ICC 167</docidentifier>
                   <biblio-tag>ICC 167, </biblio-tag>
                </bibitem>
                <note>
                   <fmt-name>
                      <span class="fmt-caption-label">
                         <span class="fmt-element-name">NOTE</span>
                      </span>
                      <span class="fmt-label-delim">
                         <tab/>
                      </span>
                   </fmt-name>
                   <p>This is an annotation of ISO 20483:2013-2014</p>
                </note>
                <bibitem id="zip_ffs">
                   <formattedref format="application/x-isodoc+xml">Title 5</formattedref>
                   <docidentifier type="metanorma-ordinal">[2]</docidentifier>
                   <biblio-tag>[2] </biblio-tag>
                </bibitem>
             </references>
          </sections>
          <bibliography>
             <references id="_" obligation="informative" normative="false" displayorder="10">
                <title id="_">Bibliography</title>
                <fmt-title depth="1">
                   <semx element="title" source="_">Bibliography</semx>
                </fmt-title>
                <bibitem id="ISBN" type="book">
                   <formattedref>
                      <em>Chemicals for analytical laboratory use</em>
                      . n.p.: n.d.
                   </formattedref>
                   <docidentifier type="metanorma-ordinal">[3]</docidentifier>
                   <docidentifier type="ISBN">ISBN</docidentifier>
                   <biblio-tag>
                      [3]
                      <tab/>
                   </biblio-tag>
                </bibitem>
                <bibitem id="ISSN" type="journal">
                   <formattedref>
                      <em>Instruments for analytical laboratory use</em>
                      . n.d.
                   </formattedref>
                   <docidentifier type="metanorma-ordinal">[4]</docidentifier>
                   <docidentifier type="ISSN">ISSN</docidentifier>
                   <biblio-tag>
                      [4]
                      <tab/>
                   </biblio-tag>
                </bibitem>
                <note>
                   <fmt-name>
                      <span class="fmt-caption-label">
                         <span class="fmt-element-name">NOTE</span>
                      </span>
                      <span class="fmt-label-delim">
                         <tab/>
                      </span>
                   </fmt-name>
                   <p>This is an annotation of document ISSN.</p>
                </note>
                <note>
                   <fmt-name>
                      <span class="fmt-caption-label">
                         <span class="fmt-element-name">NOTE</span>
                      </span>
                      <span class="fmt-label-delim">
                         <tab/>
                      </span>
                   </fmt-name>
                   <p>This is another annotation of document ISSN.</p>
                </note>
                <bibitem id="ISO3696" type="standard">
                   <formattedref>
                      <em>
                         <span class="stddocTitle">Water for analytical laboratory use</span>
                      </em>
                      .
                   </formattedref>
                   <docidentifier type="metanorma-ordinal">[5]</docidentifier>
                   <docidentifier type="ISO">ISO 3696</docidentifier>
                   <docidentifier scope="biblio-tag">ISO 3696</docidentifier>
                   <biblio-tag>
                      [5]
                      <tab/>
                      ISO 3696,
                   </biblio-tag>
                </bibitem>
                <bibitem id="ref10">
                   <formattedref format="application/x-isodoc+xml">
                      <smallcap>Standard No I.C.C 167</smallcap>
                      .
                      <em>Determination of the protein content in cereal and cereal products for food and animal feeding stuffs according to the Dumas combustion method</em>
                      (see
                      <link target="http://www.icc.or.at" id="_"/>
                      <semx element="link" source="_">
                         <fmt-link target="http://www.icc.or.at"/>
                      </semx>
                      )
                   </formattedref>
                   <docidentifier type="metanorma-ordinal">[6]</docidentifier>
                   <biblio-tag>
                      [6]
                      <tab/>
                   </biblio-tag>
                </bibitem>
                <bibitem id="ref11">
                   <formattedref>
                      <em>
                         <span class="stddocTitle">Internet Calendaring and Scheduling Core Object Specification (iCalendar)</span>
                      </em>
                      .
                   </formattedref>
                   <docidentifier type="metanorma-ordinal">[7]</docidentifier>
                   <docidentifier type="IETF">IETF RFC 10</docidentifier>
                   <docidentifier scope="biblio-tag">IETF RFC 10</docidentifier>
                   <biblio-tag>
                      [7]
                      <tab/>
                      IETF RFC 10,
                   </biblio-tag>
                </bibitem>
                <bibitem id="ref12" type="standard">
                   <formattedref format="application/x-isodoc+xml">
                      CitationWorks. 2019.
                      <em>How to cite a reference</em>
                      .
                   </formattedref>
                   <docidentifier type="metanorma">[Citn]</docidentifier>
                   <docidentifier type="IETF">IETF RFC 20</docidentifier>
                   <docidentifier scope="biblio-tag">IETF RFC 20</docidentifier>
                   <biblio-tag>
                      Citn
                      <tab/>
                      IETF RFC 20,
                   </biblio-tag>
                </bibitem>
             </references>
          </bibliography>
       </iso-standard>
    OUTPUT

    html = <<~OUTPUT
      #{HTML_HDR}
                <div id="_">
                   <h1 class="ForewordTitle">FOREWORD</h1>
                   <p id="_">
                      <a href="#ISO712">ISO 712</a>
                      <a href="#ISBN">[3]</a>
                      <a href="#ISSN">[4]</a>
                      <a href="#ISO16634">ISO 16634:-- (all parts)</a>
                      <a href="#ref1">ICC 167</a>
                      <a href="#ref10">[6]</a>
                      <a href="#ref12">Citn</a>
                      <a href="#zip_ffs">[2]</a>
                   </p>
                </div>
            #{IEC_TITLE1}
                <div>
                   <h1>1  Normative References</h1>
                   <p>The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
                   <p id="ISO712" class="NormRef">
                      [1], ISO 712,
                      <i>
                         <span class="stddocTitle">Cereals and cereal products</span>
                      </i>
                   </p>
                   <p id="ISO16634" class="NormRef">
                      ISO 16634:-- (all parts)
                      <a class="FootnoteRef" href="#fn:1">
                         <sup>1</sup>
                      </a>
                      ,
                      <i>
                         <span class="stddocTitle">Cereals, pulses, milled cereal products, oilseeds and animal feeding stuffs</span>
                      </i>
                      .
                   </p>
                   <p id="ISO20483" class="NormRef">
                      ISO 20483:2013-2014,
                      <i>
                         <span class="stddocTitle">Cereals and pulses</span>
                      </i>
                   </p>
                   <p id="ref1" class="NormRef">
                      ICC 167,
                      <span style="font-variant:small-caps;">Standard No I.C.C 167</span>
                      .
                      <i>Determination of the protein content in cereal and cereal products for food and animal feeding stuffs according to the Dumas combustion method</i>
                      (see
                      <a href="http://www.icc.or.at">http://www.icc.or.at</a>
                      )
                   </p>
                   <div class="Note">
                      <p>
                         <span class="note_label">NOTE  </span>
                         This is an annotation of ISO 20483:2013-2014
                      </p>
                   </div>
                   <p id="zip_ffs" class="NormRef">[2] Title 5</p>
                </div>
                <br/>
                <div>
                   <h1 class="Section3">Bibliography</h1>
                   <p id="ISBN" class="Biblio">
                      [3] 
                      <i>Chemicals for analytical laboratory use</i>
                      . n.p.: n.d.
                   </p>
                   <p id="ISSN" class="Biblio">
                      [4] 
                      <i>Instruments for analytical laboratory use</i>
                      . n.d.
                   </p>
                   <div class="Note">
                      <p>
                         <span class="note_label">NOTE  </span>
                         This is an annotation of document ISSN.
                      </p>
                   </div>
                   <div class="Note">
                      <p>
                         <span class="note_label">NOTE  </span>
                         This is another annotation of document ISSN.
                      </p>
                   </div>
                   <p id="ISO3696" class="Biblio">
                      [5]  ISO 3696,
                      <i>
                         <span class="stddocTitle">Water for analytical laboratory use</span>
                      </i>
                      .
                   </p>
                   <p id="ref10" class="Biblio">
                      [6] 
                      <span style="font-variant:small-caps;">Standard No I.C.C 167</span>
                      .
                      <i>Determination of the protein content in cereal and cereal products for food and animal feeding stuffs according to the Dumas combustion method</i>
                      (see
                      <a href="http://www.icc.or.at">http://www.icc.or.at</a>
                      )
                   </p>
                   <p id="ref11" class="Biblio">
                      [7]  IETF RFC 10,
                      <i>
                         <span class="stddocTitle">Internet Calendaring and Scheduling Core Object Specification (iCalendar)</span>
                      </i>
                      .
                   </p>
                   <p id="ref12" class="Biblio">
                      Citn  IETF RFC 20, CitationWorks. 2019.
                      <i>How to cite a reference</i>
                      .
                   </p>
                </div>
                <aside id="fn:1" class="footnote">
                   <p>Under preparation. (Stage at the time of publication ISO/DIS 16634)</p>
                </aside>
             </div>
          </body>
       </html>
    OUTPUT
    pres_output = IsoDoc::Iec::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true)
    expect(Xml::C14n.format(strip_guid(pres_output
      .sub(%r{<localized-strings>.*</localized-strings>}m, "")
      .gsub(%r{reference="[^"]+"}m, 'reference="1"'))))
      .to be_equivalent_to Xml::C14n.format(presxml)
    expect(Xml::C14n.format(strip_guid(IsoDoc::Iec::HtmlConvert.new({})
      .convert("test", pres_output.gsub(%r{reference="[^"]+"}m, 'reference="1"'),
               true)))).to be_equivalent_to Xml::C14n.format(html)
  end
end
