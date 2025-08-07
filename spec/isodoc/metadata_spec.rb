require "spec_helper"
require "nokogiri"

RSpec.describe IsoDoc::Iec::Metadata do
  it "processes IsoXML metadata #1" do
    c = IsoDoc::Iec::HtmlConvert.new({})
    c.convert_init(<<~"INPUT", "test", false)
      <iec-standard xmlns="http://riboseinc.com/isoxml">
    INPUT
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata type="standard">
          <title type="title-intro" language="en" format="text/plain">Cereals and pulses</title>
          <title type="title-main" language="en" format="text/plain">Specifications and test methods</title>
          <title type="title-part" language="en" format="text/plain">Rice</title>
          <title type="title-intro" language="fr" format="text/plain">Céréales et légumineuses</title>
          <title type="title-main" language="fr" format="text/plain">Spécification et méthodes d'essai</title>
          <title type="title-part" language="fr" format="text/plain">Riz</title>
        <docidentifier type="ISO">ISO/PreCD3 17301-1</docidentifier>
        <docidentifier type="iso-tc">17301</docidentifier>
        <docnumber>1730</docnumber>
        <date type="published"><on>2011</on></date>
        <date type="accessed"><on>2012</on></date>
        <date type="created"><from>2010</from><to>2011</to></date>
        <date type="activated"><on>2013</on></date>
        <date type="obsoleted"><on>2014</on></date>
        <edition>2</edition>
        <version>
        <revision-date>2016-05-01</revision-date>
        <draft>0.4</draft>
      </version>
        <contributor>
          <role type="author"/>
          <organization>
            <name>International Organization for Standardization</name>
            <abbreviation>ISO</abbreviation>
          </organization>
        </contributor>
          <contributor>
             <role type="author">
                <description>committee</description>
             </role>
             <organization>
                <name>International Electrotechnical Commission</name>
                <subdivision type="Technical committee" subtype="TC">
                   <name>Electrical equipment in medical practice</name>
                   <identifier>TC 62</identifier>
                   <identifier type="full">IEC TC 62</identifier>
                </subdivision>
                <abbreviation>IEC</abbreviation>
             </organization>
          </contributor>
          <contributor>
             <role type="author">
                <description>committee</description>
             </role>
             <organization>
                <name>International Organization for Standardization</name>
                <subdivision type="Technical committee" subtype="TC">
                   <name>Quality management and corresponding general aspects for medical devices</name>
                   <identifier>TC 210</identifier>
                   <identifier type="full">TC 210/SC 62A/WG 62A1</identifier>
                </subdivision>
                <subdivision type="Subcommittee" subtype="SC">
                   <name>Common aspects of electrical equipment used in medical practice</name>
                   <identifier>SC 62A</identifier>
                </subdivision>
                <subdivision type="Workgroup" subtype="WG">
                   <name>Working group on defibulators</name>
                   <identifier>WG 62A1</identifier>
                </subdivision>
                <abbreviation>ISO</abbreviation>
             </organization>
          </contributor>
          <contributor>
             <role type="author">
                <description>committee</description>
             </role>
             <organization>
                <name>Institute of Electrical and Electronic Engineers</name>
                <subdivision type="Technical committee" subtype="TC">
                   <name>The committee</name>
                </subdivision>
                <abbreviation>IEEE</abbreviation>
             </organization>
          </contributor>
             <contributor>
      <role type="author">
         <description>secretariat</description>
      </role>
      <organization>
         <name>International Organization for Standardization</name>
         <subdivision type="Secretariat">
            <name>GB</name>
         </subdivision>
         <abbreviation>ISO</abbreviation>
      </organization>
   </contributor>
        <contributor>
          <role type="publisher"/>
          <organization>
            <name>International Organization for Standardization</name>
            <abbreviation>ISO</abbreviation>
          </organization>
        </contributor>
        <language>en</language>
        <script>Latn</script>
        <status>
          <stage abbreviation="CD">35</stage>
          <substage abbreviation="3CD">20</substage>
          <iteration>3</iteration>
        </status>
        <copyright>
          <from>2016</from>
          <owner>
            <organization>
              <abbreviation>ISO</abbreviation>
            </organization>
          </owner>
        </copyright>
        <ext>
        <doctype language=''>international-standard</doctype>
        <doctype language='fr'>Norme international</doctype>
        <doctype language='en'>International Standard</doctype>
      <horizontal language=''>true</horizontal>
      <horizontal language='fr'>Norme horizontale</horizontal>
      <horizontal language='en'>Horizontal Standard</horizontal>
      <function language=''>emc</function>
      <function language='fr'>Publication fondamentale en CEM</function>
      <function language='en'>Basic EMC Publication</function>
        <editorialgroup identifier="TC 34/SC 4/WG 3">
          <technical-committee number="34">Food products</technical-committee>
          <subcommittee number="4">Cereals and pulses</subcommittee>
          <workgroup number="3">Rice Group</workgroup>
          <secretariat>GB</secretariat>
        </editorialgroup>
        <structuredidentifier>
          <project-number part="1">ISO/PreCD3 17301</project-number>
        </structuredidentifier>
        </ext>
      </bibdata>
      </iso-standard>
    INPUT
    output =
      { accesseddate: "2012",
        activateddate: "2013",
        agency: "ISO",
        createddate: "2010&#x2013;2011",
        docnumber: "ISO/PreCD3 17301-1",
        docnumeric: "1730",
        docsubtitle: "C&#xe9;r&#xe9;ales et l&#xe9;gumineuses&#xa0;&#x2014; Sp&#xe9;cification et m&#xe9;thodes d&#x27;essai&#xa0;&#x2014; Partie&#xa0;1: Riz",
        docsubtitleintro: "C&#xe9;r&#xe9;ales et l&#xe9;gumineuses",
        docsubtitlemain: "Sp&#xe9;cification et m&#xe9;thodes d&#x27;essai",
        docsubtitlepart: "Riz",
        docsubtitlepartlabel: "Partie&#xa0;1",
        doctitle: "Cereals and pulses&#xa0;&#x2014; Specifications and test methods&#xa0;&#x2014; Part&#xa0;1: Rice",
        doctitleintro: "Cereals and pulses",
        doctitlemain: "Specifications and test methods",
        doctitlepart: "Rice",
        doctitlepartlabel: "Part&#xa0;1",
        doctype: "International Standard",
        doctype_display: "International Standard",
        doctype_en: "International Standard",
        doctype_fr: "Norme International",
        docyear: "2016",
        draft: "0.4",
        draftinfo: " (draft 0.4, 2016-05-01)",
        edition: "2",
        editorialgroup: "IEC TC 62 and TC 210/SC 62A/WG 62A1",
        function: "Emc",
        function_display: "Basic EMC Publication",
        function_en: "Basic EMC Publication",
        function_fr: "Publication Fondamentale En CEM",
        horizontal: "True",
        horizontal_display: "Horizontal Standard",
        horizontal_en: "Horizontal Standard",
        horizontal_fr: "Norme Horizontale",
        lang: "en",
        obsoleteddate: "2014",
        publisheddate: "2011",
        publisher: "International Organization for Standardization",
        revdate: "2016-05-01",
        revdate_monthyear: "May 2016",
        sc: "SC 62A",
        script: "Latn",
        secretariat: "GB",
        stage: "35",
        stage_int: 35,
        stageabbr: "CD",
        statusabbr: "3CD",
        tc: "TC 62",
        tc_docnumber: ["17301"],
        unpublished: false,
        wg: "WG 62A1" }
    expect(metadata(c.info(Nokogiri::XML(input), nil)))
      .to be_equivalent_to output
  end

  it "processes IsoXML metadata #2" do
    c = IsoDoc::Iec::HtmlConvert.new({})
    c.convert_init(<<~"INPUT", "test", false)
      <iso-standard xmlns="http://riboseinc.com/isoxml">
    INPUT
    input = <<~INPUT
          <iso-standard xmlns="http://riboseinc.com/isoxml">
          <bibdata type="standard">
          <title type="title-intro" language="en" format="text/plain">Cereals and pulses</title>
          <title type="title-main" language="en" format="text/plain">Specifications and test methods</title>
          <title type="title-part" language="en" format="text/plain">Rice</title>
          <title type="title-intro" language="fr" format="text/plain">Céréales et légumineuses</title>
          <title type="title-main" language="fr" format="text/plain">Spécification et méthodes d'essai</title>
          <title type="title-part" language="fr" format="text/plain">Riz</title>
        <docidentifier type="ISO">ISO/IEC/CD 17301-1-3</docidentifier>
        <docidentifier type="iso-tc">17301</docidentifier>
        <contributor>
          <role type="author"/>
          <organization>
          <name>International Organization for Standardization</name>
            <abbreviation>ISO</abbreviation>
          </organization>
        </contributor>
        <contributor>
          <role type="publisher"/>
          <organization>
            <name>International Organization for Standardization</name>
            <abbreviation>ISO</abbreviation>
           </organization>
        </contributor>
        <contributor>
          <role type="publisher"/>
          <organization>
            <name>International Electrotechnical Commission</name>
            <abbreviation>IEC</abbreviation>
          </organization>
        </contributor>
        <language>en</language>
        <script>Latn</script>
        <status>
          <stage abbreviation="FDIS">50</stage>
          <substage abbreviation="CFDIS">20</substage>
        </status>
        <copyright>
          <from>2016</from>
          <owner>
            <organization>
              <name>International Organization for Standardization</name>
            </organization>
          </owner>
        </copyright>
        <relation type="obsoletes">
          <locality type="clause"><referenceFrom>3.1</referenceFrom></locality>
          <docidentifier>IEC 8121</docidentifier>
        </relation>
        <ext>
        <doctype>technical-report</doctype>
        <horizontal>false</horizontal>
        <editorialgroup>
          <technical-committee number="34" type="ABC">Food products</technical-committee>
          <subcommittee number="4" type="DEF">Cereals and pulses</subcommittee>
          <workgroup number="3" type="GHI">Rice Group</workgroup>
        </editorialgroup>
        <ics><code>1.2.3</code></ics>
        <ics><code>1.2.3</code></ics>
          <structuredidentifier>
          <project-number part="1" subpart="3">ISO/IEC/CD 17301</project-number>
        </strucuredidentifier>
        </ext>
      </bibdata>
      </iso-standard>
    INPUT
    output =
      { agency: "ISO/IEC",
        docnumber: "ISO/IEC/CD 17301-1-3",
        docsubtitle: "C&#xe9;r&#xe9;ales et l&#xe9;gumineuses&#xa0;&#x2014; Sp&#xe9;cification et m&#xe9;thodes d&#x27;essai&#xa0;&#x2014; Partie&#xa0;1&#x2013;3: Riz",
        docsubtitleintro: "C&#xe9;r&#xe9;ales et l&#xe9;gumineuses",
        docsubtitlemain: "Sp&#xe9;cification et m&#xe9;thodes d&#x27;essai",
        docsubtitlepart: "Riz",
        docsubtitlepartlabel: "Partie&#xa0;1&#x2013;3",
        doctitle: "Cereals and pulses&#xa0;&#x2014; Specifications and test methods&#xa0;&#x2014; Part&#xa0;1&#x2013;3: Rice",
        doctitleintro: "Cereals and pulses",
        doctitlemain: "Specifications and test methods",
        doctitlepart: "Rice",
        doctitlepartlabel: "Part&#xa0;1&#x2013;3",
        doctype: "Technical Report",
        doctype_display: "Technical Report",
        doctype_en: "Technical Report",
        doctype_fr: "Technical Report",
        docyear: "2016",
        horizontal: "False",
        ics: "1.2.3, 1.2.3",
        lang: "en",
        obsoletes: "IEC 8121",
        obsoletes_part: "3.1",
        publisher: "International Organization for Standardization and International Electrotechnical Commission",
        script: "Latn",
        stage: "50",
        stage_int: 50,
        stageabbr: "FDIS",
        statusabbr: "CFDIS",
        tc_docnumber: ["17301"],
        unpublished: false }
    expect(metadata(c.info(Nokogiri::XML(input), nil)))
      .to be_equivalent_to output
  end
end
