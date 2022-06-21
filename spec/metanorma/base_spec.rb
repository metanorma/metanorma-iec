require "spec_helper"
require "fileutils"

RSpec.describe Metanorma::Iec do
  before(:all) do
    @blank_hdr = blank_hdr_gen
  end

  it "has a version number" do
    expect(Metanorma::Iec::VERSION).not_to be nil
  end

  it "processes a blank document" do
    input = <<~INPUT
      #{ASCIIDOC_BLANK_HDR}
    INPUT
    output = <<~OUTPUT
          #{@blank_hdr}
      <sections/>
      </iec-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end

  it "converts a blank document" do
    FileUtils.rm_f "test.doc"
    FileUtils.rm_f "test.html"
    FileUtils.rm_f "test.pdf"
    input = <<~INPUT
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
      :no-isobib:
    INPUT
    output = <<~OUTPUT
          #{@blank_hdr}
      <sections/>
      </iec-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
    expect(File.exist?("test.pdf")).to be true
    expect(File.exist?("test.html")).to be true
    expect(File.exist?("test.doc")).to be true
    expect(File.exist?("htmlstyle.css")).to be false
  end

  it "processes default metadata" do
    input = <<~INPUT
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :no-isobib:
      :docnumber: 1000
      :partnumber: 1
      :edition: 2
      :revdate: 2000-01-01
      :draft: 0.3.4
      :technical-committee: TC
      :technical-committee-number: 1
      :technical-committee-type: A
      :subcommittee: SC
      :subcommittee-number: 2
      :subcommittee-type: B
      :workgroup: WG
      :workgroup-number: 3
      :workgroup-type: C
      :technical-committee_2: TC1
      :technical-committee-number_2: 11
      :technical-committee-type_2: A1
      :subcommittee_2: SC1
      :subcommittee-number_2: 21
      :subcommittee-type_2: B1
      :workgroup_2: WG1
      :workgroup-number_2: 31
      :workgroup-type_2: C1
      :secretariat: SECRETARIAT
      :docstage: 10
      :docsubstage: 20
      :iteration: 3
      :language: en
      :title-intro-en: Introduction
      :title-main-en: Main Title -- Title
      :title-part-en: Title Part
      :title-intro-fr: Introduction Française
      :title-main-fr: Titre Principal
      :title-part-fr: Part du Titre
      :library-ics: 1,2,3
      :accessibility-color-inside: true
      :price-code: XC
      :cen-processing: true
      :secretary: Fred Nerk
      :interest-to-committees: TC 6121, SC 12
      :obsoletes: ABC; DEF
    INPUT
    output = <<~OUTPUT
                <?xml version="1.0" encoding="UTF-8"?>
            <iec-standard xmlns="https://www.metanorma.org/ns/iec" type="semantic" version="#{Metanorma::Iec::VERSION}">
                     <bibdata type='standard'>
          <title language='en' format='text/plain' type='main'>
            Introduction&#8201;&#8212;&#8201;Main
            Title&#8201;&#8212;&#8201;Title&#8201;&#8212;&#8201;Title Part
          </title>
          <title language='en' format='text/plain' type='title-intro'>Introduction</title>
          <title language='en' format='text/plain' type='title-main'>Main Title&#8201;&#8212;&#8201;Title</title>
          <title language='en' format='text/plain' type='title-part'>Title Part</title>
          <title language='fr' format='text/plain' type='main'>
            Introduction Fran&#231;aise&#8201;&#8212;&#8201;Titre
            Principal&#8201;&#8212;&#8201;Part du Titre
          </title>
          <title language='fr' format='text/plain' type='title-intro'>Introduction Fran&#231;aise</title>
          <title language='fr' format='text/plain' type='title-main'>Titre Principal</title>
          <title language='fr' format='text/plain' type='title-part'>Part du Titre</title>
          <docidentifier type='ISO'>IEC/3NWIP 1000-1 ED 2</docidentifier>
          <docnumber>1000</docnumber>
          <contributor>
            <role type='author'/>
            <organization>
              <name>International Electrotechnical Commission</name>
              <abbreviation>IEC</abbreviation>
            </organization>
          </contributor>
          <contributor>
            <role type='publisher'/>
            <organization>
              <name>International Electrotechnical Commission</name>
              <abbreviation>IEC</abbreviation>
            </organization>
          </contributor>
          <edition>2</edition>
          <version>
            <revision-date>2000-01-01</revision-date>
            <draft>0.3.4</draft>
          </version>
          <language>en</language>
          <script>Latn</script>
          <status>
            <stage abbreviation='NWIP'>10</stage>
            <substage abbreviation='??'>20</substage>
            <iteration>3</iteration>
          </status>
          <copyright>
            <from>#{Date.today.year}</from>
            <owner>
              <organization>
                <name>International Electrotechnical Commission</name>
                <abbreviation>IEC</abbreviation>
              </organization>
            </owner>
          </copyright>
          <relation type='obsoletes'>
            <bibitem>
              <title>--</title>
              <docidentifier>ABC</docidentifier>
            </bibitem>
          </relation>
          <relation type='obsoletes'>
            <bibitem>
              <title>--</title>
              <docidentifier>DEF</docidentifier>
            </bibitem>
          </relation>
          <ext>
            <doctype>standard</doctype>
            <editorialgroup>
              <agency>IEC</agency>
              <technical-committee number='1' type='A'>TC</technical-committee>
              <technical-committee number='11' type='A1'>TC1</technical-committee>
              <subcommittee number='2' type='B'>SC</subcommittee>
              <subcommittee number='21' type='B1'>SC1</subcommittee>
              <workgroup number='3' type='C'>WG</workgroup>
              <workgroup number='31' type='C1'>WG1</workgroup>
              <secretariat>SECRETARIAT</secretariat>
            </editorialgroup>
            <ics>
              <code>1</code>
            </ics>
            <ics>
              <code>2</code>
            </ics>
            <ics>
              <code>3</code>
            </ics>
            <structuredidentifier>
              <project-number part='1'>IEC 1000</project-number>
            </structuredidentifier>
            <stagename>New work item proposal</stagename>
            <accessibility-color-inside>true</accessibility-color-inside>
            <price-code>XC</price-code>
            <cen-processing>true</cen-processing>
            <secretary>Fred Nerk</secretary>
            <interest-to-committees>TC 6121, SC 12</interest-to-committees>
          </ext>
        </bibdata>
        <boilerplate>
          <copyright-statement>
            <clause>
              <p id='_'>
                <strong>Copyright &#169; #{Date.today.year} International Electrotechnical Commission, IEC.</strong>
                 All rights reserved. It is permitted to download this electronic
                file, to make a copy and to print out the content for the sole purpose
                of preparing National Committee positions. You may not copy or
                &#8220;mirror&#8221; the file or printed version of the document, or
                any part of it, for any other purpose without permission in writing
                from IEC.
              </p>
            </clause>
          </copyright-statement>
          <legal-statement>
            <clause>
              <ol id='_'>
                <li>
                  <p id='_'>
                    The International Electrotechnical Commission (IEC) is a worldwide
                    organization for standardization comprising all national
                    electrotechnical committees (IEC National Committees). The object
                    of IEC is to promote international co-operation on all questions
                    concerning standardization in the electrical and electronic
                    fields. To this end and in addition to other activities, IEC
                    publishes International Standards, Technical Specifications,
                    Technical Reports, Publicly Available Specifications (PAS) and
                    Guides (hereafter referred to as &#8220;IEC
                    Publication(s)&#8221;). Their preparation is entrusted to
                    technical committees; any IEC National Committee interested in the
                    subject dealt with may participate in this preparatory work.
                    International, governmental and non-governmental organizations
                    liaising with the IEC also participate in this preparation. IEC
                    collaborates closely with the International Organization for
                    Standardization (ISO) in accordance with conditions determined by
                    agreement between the two organizations.
                  </p>
                </li>
                <li>
                  <p id='_'>
                    The formal decisions or agreements of IEC on technical matters
                    express, as nearly as possible, an international consensus of
                    opinion on the relevant subjects since each technical committee
                    has representation from all interested IEC National Committees.
                  </p>
                </li>
                <li>
                  <p id='_'>
                    IEC Publications have the form of recommendations for
                    international use and are accepted by IEC National Committees in
                    that sense. While all reasonable efforts are made to ensure that
                    the technical content of IEC Publications is accurate, IEC cannot
                    be held responsible for the way in which they are used or for any
                    misinterpretation by any end user.
                  </p>
                </li>
                <li>
                  <p id='_'>
                    In order to promote international uniformity, IEC National
                    Committees undertake to apply IEC Publications transparently to
                    the maximum extent possible in their national and regional
                    publications. Any divergence between any IEC Publication and the
                    corresponding national or regional publication shall be clearly
                    indicated in the latter.
                  </p>
                </li>
                <li>
                  <p id='_'>
                    IEC itself does not provide any attestation of conformity.
                    Independent certification bodies provide conformity assessment
                    services and, in some areas, access to IEC marks of conformity.
                    IEC is not responsible for any services carried out by independent
                    certification bodies.
                  </p>
                </li>
                <li>
                  <p id='_'>All users should ensure that they have the latest edition of this publication.</p>
                </li>
                <li>
                  <p id='_'>
                    No liability shall attach to IEC or its directors, employees,
                    servants or agents including individual experts and members of its
                    technical committees and IEC National Committees for any personal
                    injury, property damage or other damage of any nature whatsoever,
                    whether direct or indirect, or for costs (including legal fees)
                    and expenses arising out of the publication, use of, or reliance
                    upon, this IEC Publication or any other IEC Publications.
                  </p>
                </li>
                <li>
                  <p id='_'>
                    Attention is drawn to the Normative references cited in this
                    publication. Use of the referenced publications is indispensable
                    for the correct application of this publication.
                  </p>
                </li>
                <li>
                  <p id='_'>
                    Attention is drawn to the possibility that some of the elements of
                    this IEC Publication may be the subject of patent rights. IEC
                    shall not be held responsible for identifying any or all such
                    patent rights.
                  </p>
                </li>
              </ol>
            </clause>
          </legal-statement>
          <license-statement>
            <clause>
              <p id='_'>
                This document is still under study and subject to change. It should
                not be used for reference purposes. until published as such.
              </p>
              <p id='_'>
                Recipients of this document are invited to submit, with their
                comments, notification of any relevant patent rights of which they are
                aware and to provide supporting documentation.
              </p>
            </clause>
          </license-statement>
          <feedback-statement>
            <clause id='boilerplate-cenelec-attention'>
              <title>Attention IEC-CENELEC parallel voting</title>
              <p id='_'>
                The attention of IEC National Committees, members of CENELEC, is drawn
                to the fact that this (NWIP) is submitted for parallel voting.
              </p>
              <p id='_'>The CENELEC members are invited to vote through the CENELEC voting system.</p>
            </clause>
          </feedback-statement>
        </boilerplate>
        <sections> </sections>
      </iec-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end

  it "processes complex metadata" do
    input = <<~INPUT
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :no-isobib:
      :docnumber: 1000
      :partnumber: 1-1
      :tc-docnumber: 2000
      :language: el
      :script: Grek
      :publisher: IEC;IETF;ISO
      :copyright-year: 2001
      :docstage: A2CD
      :doctype: technical-specification
      :function: emc
      :horizontal: true
    INPUT
    output = <<~OUTPUT
           <?xml version="1.0" encoding="UTF-8"?>
            <iec-standard xmlns="https://www.metanorma.org/ns/iec" type="semantic" version="#{Metanorma::Iec::VERSION}">
                     <bibdata type='standard'>
          <docidentifier type='ISO'>IEC/IETF/ISO/2CDTS 1000-1-1 ED 1</docidentifier>
          <docidentifier type='iso-tc'>2000</docidentifier>
          <docnumber>1000</docnumber>
          <contributor>
            <role type='author'/>
            <organization>
              <name>International Electrotechnical Commission</name>
              <abbreviation>IEC</abbreviation>
            </organization>
          </contributor>
          <contributor>
            <role type='author'/>
            <organization>
              <name>IETF</name>
            </organization>
          </contributor>
          <contributor>
            <role type='author'/>
            <organization>
              <name>International Organization for Standardization</name>
              <abbreviation>ISO</abbreviation>
            </organization>
          </contributor>
          <contributor>
            <role type='publisher'/>
            <organization>
              <name>International Electrotechnical Commission</name>
              <abbreviation>IEC</abbreviation>
            </organization>
          </contributor>
          <contributor>
            <role type='publisher'/>
            <organization>
              <name>IETF</name>
            </organization>
          </contributor>
          <contributor>
            <role type='publisher'/>
            <organization>
              <name>International Organization for Standardization</name>
              <abbreviation>ISO</abbreviation>
            </organization>
          </contributor>
          <language>el</language>
          <script>Grek</script>
          <status>
            <stage abbreviation='CD'>30</stage>
            <substage abbreviation='A22CD'>99</substage>
            <iteration>2</iteration>
          </status>
          <copyright>
            <from>2001</from>
            <owner>
              <organization>
                <name>International Electrotechnical Commission</name>
                <abbreviation>IEC</abbreviation>
              </organization>
            </owner>
          </copyright>
          <copyright>
            <from>2001</from>
            <owner>
              <organization>
                <name>IETF</name>
              </organization>
            </owner>
          </copyright>
          <copyright>
            <from>2001</from>
            <owner>
              <organization>
                <name>International Organization for Standardization</name>
                <abbreviation>ISO</abbreviation>
              </organization>
            </owner>
          </copyright>
          <ext>
            <doctype>technical-specification</doctype>
            <horizontal>true</horizontal>
            <function>emc</function>
            <editorialgroup>
              <agency>IEC</agency>
              <agency>IETF</agency>
              <agency>ISO</agency>
            </editorialgroup>
            <structuredidentifier>
              <project-number part='1' subpart='1'>IEC/IETF/ISO 1000</project-number>
            </structuredidentifier>
            <stagename>Committee draft</stagename>
          </ext>
        </bibdata>
        <boilerplate>
          <copyright-statement>
            <clause>
              <p id='_'>
                <strong>Copyright &#169; 2001 International Electrotechnical Commission, IEC.</strong>
                 All rights reserved. It is permitted to download this electronic
                file, to make a copy and to print out the content for the sole purpose
                of preparing National Committee positions. You may not copy or
                &#8220;mirror&#8221; the file or printed version of the document, or
                any part of it, for any other purpose without permission in writing
                from IEC.
              </p>
            </clause>
          </copyright-statement>
          <legal-statement>
            <clause>
              <ol id='_'>
                <li>
                  <p id='_'>
                    The International Electrotechnical Commission (IEC) is a worldwide
                    organization for standardization comprising all national
                    electrotechnical committees (IEC National Committees). The object
                    of IEC is to promote international co-operation on all questions
                    concerning standardization in the electrical and electronic
                    fields. To this end and in addition to other activities, IEC
                    publishes International Standards, Technical Specifications,
                    Technical Reports, Publicly Available Specifications (PAS) and
                    Guides (hereafter referred to as &#8220;IEC
                    Publication(s)&#8221;). Their preparation is entrusted to
                    technical committees; any IEC National Committee interested in the
                    subject dealt with may participate in this preparatory work.
                    International, governmental and non-governmental organizations
                    liaising with the IEC also participate in this preparation. IEC
                    collaborates closely with the International Organization for
                    Standardization (ISO) in accordance with conditions determined by
                    agreement between the two organizations.
                  </p>
                </li>
                <li>
                  <p id='_'>
                    The formal decisions or agreements of IEC on technical matters
                    express, as nearly as possible, an international consensus of
                    opinion on the relevant subjects since each technical committee
                    has representation from all interested IEC National Committees.
                  </p>
                </li>
                <li>
                  <p id='_'>
                    IEC Publications have the form of recommendations for
                    international use and are accepted by IEC National Committees in
                    that sense. While all reasonable efforts are made to ensure that
                    the technical content of IEC Publications is accurate, IEC cannot
                    be held responsible for the way in which they are used or for any
                    misinterpretation by any end user.
                  </p>
                </li>
                <li>
                  <p id='_'>
                    In order to promote international uniformity, IEC National
                    Committees undertake to apply IEC Publications transparently to
                    the maximum extent possible in their national and regional
                    publications. Any divergence between any IEC Publication and the
                    corresponding national or regional publication shall be clearly
                    indicated in the latter.
                  </p>
                </li>
                <li>
                  <p id='_'>
                    IEC itself does not provide any attestation of conformity.
                    Independent certification bodies provide conformity assessment
                    services and, in some areas, access to IEC marks of conformity.
                    IEC is not responsible for any services carried out by independent
                    certification bodies.
                  </p>
                </li>
                <li>
                  <p id='_'>All users should ensure that they have the latest edition of this publication.</p>
                </li>
                <li>
                  <p id='_'>
                    No liability shall attach to IEC or its directors, employees,
                    servants or agents including individual experts and members of its
                    technical committees and IEC National Committees for any personal
                    injury, property damage or other damage of any nature whatsoever,
                    whether direct or indirect, or for costs (including legal fees)
                    and expenses arising out of the publication, use of, or reliance
                    upon, this IEC Publication or any other IEC Publications.
                  </p>
                </li>
                <li>
                  <p id='_'>
                    Attention is drawn to the Normative references cited in this
                    publication. Use of the referenced publications is indispensable
                    for the correct application of this publication.
                  </p>
                </li>
                <li>
                  <p id='_'>
                    Attention is drawn to the possibility that some of the elements of
                    this IEC Publication may be the subject of patent rights. IEC
                    shall not be held responsible for identifying any or all such
                    patent rights.
                  </p>
                </li>
              </ol>
            </clause>
          </legal-statement>
          <license-statement>
            <clause>
              <p id='_'>
                This document is still under study and subject to change. It should
                not be used for reference purposes. until published as such.
              </p>
              <p id='_'>
                Recipients of this document are invited to submit, with their
                comments, notification of any relevant patent rights of which they are
                aware and to provide supporting documentation.
              </p>
            </clause>
          </license-statement>
          <feedback-statement>
            <clause id='boilerplate-cenelec-attention'>
              <title>Attention IEC-CENELEC parallel voting</title>
              <p id='_'>
                The attention of IEC National Committees, members of CENELEC, is drawn
                to the fact that this Committee Draft (CD) is submitted for parallel
                voting.
              </p>
              <p id='_'>The CENELEC members are invited to vote through the CENELEC voting system.</p>
            </clause>
          </feedback-statement>
        </boilerplate>
        <sections> </sections>
      </iec-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end

  it "processes boilerplate in English" do
    doc = strip_guid(Asciidoctor.convert(<<~"INPUT", *OPTIONS))
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :no-isobib:
      :docnumber: 1000
      :partnumber: 1-1
      :tc-docnumber: 2000
      :language: en
      :script: Latn
      :publisher: IEC,IETF,ISO
      :copyright-year: 2001
    INPUT
    expect(doc).to include "including individual experts"
    expect(doc).not_to include "y compris ses experts particuliers"
  end

  it "processes boilerplate in French" do
    doc = strip_guid(Asciidoctor.convert(<<~"INPUT", *OPTIONS))
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :no-isobib:
      :docnumber: 1000
      :partnumber: 1-1
      :tc-docnumber: 2000
      :language: fr
      :script: Latn
      :publisher: IEC,IETF,ISO
      :copyright-year: 2001
    INPUT
    expect(doc).not_to include "including individual experts"
    expect(doc).to include "y compris ses experts particuliers"
  end

  it "defaults substage" do
    input = <<~INPUT
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :no-isobib:
      :docnumber: 1000
      :docstage: 50
    INPUT
    output = <<~OUTPUT
          <iec-standard xmlns="https://www.metanorma.org/ns/iec"  type="semantic" version="#{Metanorma::Iec::VERSION}">
      <bibdata type="standard">
        <docidentifier type="ISO">IEC/FDIS 1000 ED 1</docidentifier>
        <docnumber>1000</docnumber>
        <contributor>
          <role type="author"/>
          <organization>
            <name>International Electrotechnical Commission</name>
            <abbreviation>IEC</abbreviation>
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
          <substage abbreviation="RFDIS">00</substage>
        </status>
        <copyright>
          <from>#{Date.today.year}</from>
          <owner>
            <organization>
              <name>International Electrotechnical Commission</name>
              <abbreviation>IEC</abbreviation>
            </organization>
          </owner>
        </copyright>
        <ext>
          <doctype>standard</doctype>
          <editorialgroup>
            <agency>IEC</agency>
          </editorialgroup>
          <structuredidentifier>
            <project-number>IEC 1000</project-number>
          </structuredidentifier>
          <stagename>Final draft international standard</stagename>
        </ext>
      </bibdata>
         <boilerplate>
                 <copyright-statement>
                   <clause>
                     <p id='_'>
                       <strong>Copyright © #{Time.now.year} International Electrotechnical Commission, IEC.</strong>
                        All rights reserved. It is permitted to download this electronic
                       file, to make a copy and to print out the content for the sole purpose
                       of preparing National Committee positions. You may not copy or
                       “mirror” the file or printed version of the document, or any part of
                       it, for any other purpose without permission in writing from IEC.
                     </p>
                   </clause>
                 </copyright-statement>
                 <legal-statement>
                   <clause>
                     <ol id='_'>
                       <li>
                         <p id='_'>
                           The International Electrotechnical Commission (IEC) is a worldwide
                           organization for standardization comprising all national
                           electrotechnical committees (IEC National Committees). The object
                           of IEC is to promote international co-operation on all questions
                           concerning standardization in the electrical and electronic
                           fields. To this end and in addition to other activities, IEC
                           publishes International Standards, Technical Specifications,
                           Technical Reports, Publicly Available Specifications (PAS) and
                           Guides (hereafter referred to as “IEC Publication(s)”). Their
                           preparation is entrusted to technical committees; any IEC National
                           Committee interested in the subject dealt with may participate in
                           this preparatory work. International, governmental and
                           non-governmental organizations liaising with the IEC also
                           participate in this preparation. IEC collaborates closely with the
                           International Organization for Standardization (ISO) in accordance
                           with conditions determined by agreement between the two
                           organizations.
                         </p>
                       </li>
                       <li>
                         <p id='_'>
                           The formal decisions or agreements of IEC on technical matters
                           express, as nearly as possible, an international consensus of
                           opinion on the relevant subjects since each technical committee
                           has representation from all interested IEC National Committees.
                         </p>
                       </li>
                       <li>
                         <p id='_'>
                           IEC Publications have the form of recommendations for
                           international use and are accepted by IEC National Committees in
                           that sense. While all reasonable efforts are made to ensure that
                           the technical content of IEC Publications is accurate, IEC cannot
                           be held responsible for the way in which they are used or for any
                           misinterpretation by any end user.
                         </p>
                       </li>
                       <li>
                         <p id='_'>
                           In order to promote international uniformity, IEC National
                           Committees undertake to apply IEC Publications transparently to
                           the maximum extent possible in their national and regional
                           publications. Any divergence between any IEC Publication and the
                           corresponding national or regional publication shall be clearly
                           indicated in the latter.
                         </p>
                       </li>
                       <li>
                         <p id='_'>
                           IEC itself does not provide any attestation of conformity.
                           Independent certification bodies provide conformity assessment
                           services and, in some areas, access to IEC marks of conformity.
                           IEC is not responsible for any services carried out by independent
                           certification bodies.
                         </p>
                       </li>
                       <li>
                         <p id='_'>All users should ensure that they have the latest edition of this publication.</p>
                       </li>
                       <li>
                         <p id='_'>
                           No liability shall attach to IEC or its directors, employees,
                           servants or agents including individual experts and members of its
                           technical committees and IEC National Committees for any personal
                           injury, property damage or other damage of any nature whatsoever,
                           whether direct or indirect, or for costs (including legal fees)
                           and expenses arising out of the publication, use of, or reliance
                           upon, this IEC Publication or any other IEC Publications.
                         </p>
                       </li>
                       <li>
                         <p id='_'>
                           Attention is drawn to the Normative references cited in this
                           publication. Use of the referenced publications is indispensable
                           for the correct application of this publication.
                         </p>
                       </li>
                       <li>
                         <p id='_'>
                           Attention is drawn to the possibility that some of the elements of
                           this IEC Publication may be the subject of patent rights. IEC
                           shall not be held responsible for identifying any or all such
                           patent rights.
                         </p>
                       </li>
                     </ol>
                   </clause>
                 </legal-statement>
                 <license-statement>
                   <clause>
                     <p id='_'>
                       This document is a draft distributed for approval. It may not be
                       referred to as an International Standard until published as such.
                     </p>
                     <p id='_'>
                       In addition to their evaluation as being acceptable for industrial,
                       technological, commercial and user purposes, Final Draft International
                       Standards may on occasion have to be considered in the light of their
                       potential to become standards to which reference may be made in
                       national regulations.
                     </p>
                     <p id='_'>
                       Recipients of this document are invited to submit, with their
                       comments, notification of any relevant patent rights of which they are
                       aware and to provide supporting documentation.
                     </p>
                   </clause>
                 </license-statement>
                 <feedback-statement>
                   <clause id='boilerplate-cenelec-attention'>
                     <title>Attention IEC-CENELEC parallel voting</title>
                     <p id='_'>
                       The attention of IEC National Committees, members of CENELEC, is drawn
                       to the fact that this Final Draft International Standard (FDIS) is
                       submitted for parallel voting.
                     </p>
                     <p id='_'>The CENELEC members are invited to vote through the CENELEC voting system.</p>
                   </clause>
                 </feedback-statement>
               </boilerplate>
      <sections/>
      </iec-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end

  it "defaults substage for stage 60" do
    input = <<~INPUT
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :no-isobib:
      :docnumber: 1000
      :docstage: 60
    INPUT
    output = <<~OUTPUT
      <iec-standard xmlns="https://www.metanorma.org/ns/iec" type="semantic" version="#{Metanorma::Iec::VERSION}">
      <bibdata type="standard">
        <docidentifier type="ISO">IEC 1000 ED 1</docidentifier>
        <docnumber>1000</docnumber>
        <contributor>
          <role type="author"/>
          <organization>
            <name>International Electrotechnical Commission</name>
            <abbreviation>IEC</abbreviation>
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
          <stage abbreviation="PPUB">60</stage>
          <substage abbreviation="PPUB">60</substage>
        </status>
        <copyright>
          <from>#{Date.today.year}</from>
          <owner>
            <organization>
              <name>International Electrotechnical Commission</name>
              <abbreviation>IEC</abbreviation>
            </organization>
          </owner>
        </copyright>
        <ext>
          <doctype>standard</doctype>
          <editorialgroup>
            <agency>IEC</agency>
          </editorialgroup>
          <structuredidentifier>
            <project-number>IEC 1000</project-number>
          </structuredidentifier>
          <stagename>International standard</stagename>
        </ext>
      </bibdata>
      #{boilerplate(Nokogiri::XML(BLANK_HDR + '</iec-standard>'))}
      <sections/>
      </iec-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end

  it "populates metadata for PRF" do
    input = <<~INPUT
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :no-isobib:
      :docnumber: 1000
      :docstage: 60
      :docsubstage: 00
    INPUT
    output = <<~OUTPUT
      <iec-standard xmlns="https://www.metanorma.org/ns/iec" type="semantic" version="#{Metanorma::Iec::VERSION}">
      <bibdata type="standard">
        <docidentifier type="ISO">IEC 1000 ED 1</docidentifier>
        <docnumber>1000</docnumber>
        <contributor>
          <role type="author"/>
          <organization>
            <name>International Electrotechnical Commission</name>
            <abbreviation>IEC</abbreviation>
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
          <stage abbreviation="PPUB">60</stage>
          <substage abbreviation="BPUB">00</substage>
        </status>
        <copyright>
          <from>#{Date.today.year}</from>
          <owner>
            <organization>
              <name>International Electrotechnical Commission</name>
              <abbreviation>IEC</abbreviation>
            </organization>
          </owner>
        </copyright>
        <ext>
          <doctype>standard</doctype>
          <editorialgroup>
            <agency>IEC</agency>
          </editorialgroup>
          <structuredidentifier>
            <project-number>IEC 1000</project-number>
          </structuredidentifier>
          <stagename>International standard</stagename>
        </ext>
      </bibdata>
      #{boilerplate(Nokogiri::XML(BLANK_HDR + '</iec-standard>'))}
      <sections/>
      </iec-standard>
    OUTPUT
    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end

  it "reads scripts into blank HTML document" do
    FileUtils.rm_f "test.html"
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
      :no-isobib:
      :no-pdf:
    INPUT
    html = File.read("test.html", encoding: "utf-8")
    expect(html).to match(%r{<script>})
  end

  it "uses default fonts" do
    FileUtils.rm_f "test.html"
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
      :no-isobib:
      :no-pdf:
    INPUT
    html = File.read("test.html", encoding: "utf-8")
    expect(html)
      .to match(%r[\bpre[^{]+\{[^{]+font-family: "Courier New", monospace;]m)
    expect(html)
      .to match(%r[blockquote[^{]+\{[^{]+font-family: "Arial", sans-serif;]m)
    expect(html)
      .to match(%r[\.h2Annex[^{]+\{[^{]+font-family: "Arial", sans-serif;]m)
  end

  it "uses Chinese fonts" do
    FileUtils.rm_f "test.html"
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
      :no-isobib:
      :script: Hans
      :no-pdf:
    INPUT
    html = File.read("test.html", encoding: "utf-8")
    expect(html)
      .to match(%r[\bpre[^{]+\{[^{]+font-family: "Courier New", monospace;]m)
    expect(html)
      .to match(%r[blockquote[^{]+\{[^{]+font-family: "Source Han Sans", serif;]m)
    expect(html)
      .to match(%r[\.h2Annex[^{]+\{[^{]+font-family: "Source Han Sans", sans-serif;]m)
  end

  it "uses specified fonts" do
    FileUtils.rm_f "test.html"
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
      :no-isobib:
      :script: Hans
      :body-font: Zapf Chancery
      :header-font: Comic Sans
      :monospace-font: Andale Mono
      :no-pdf:
    INPUT
    html = File.read("test.html", encoding: "utf-8")
    expect(html).to match(%r[\bpre[^{]+\{[^{]+font-family: Andale Mono;]m)
    expect(html)
      .to match(%r[blockquote[^{]+\{[^{]+font-family: Zapf Chancery;]m)
    expect(html).to match(%r[\.h2Annex[^{]+\{[^{]+font-family: Comic Sans;]m)
  end

  it "strips MS-specific CSS" do
    FileUtils.rm_f "test.html"
    FileUtils.rm_f "test.doc"
    Asciidoctor.convert(<<~"INPUT", *OPTIONS)
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
      :no-isobib:
      :no-pdf:
    INPUT
    word = File.read("test.doc", encoding: "utf-8")
    html = File.read("test.html", encoding: "utf-8")
    expect(word).to match(%r[mso-style-name: "Intro Title";]m)
    expect(html).not_to match(%r[mso-style-name: "Intro Title";]m)
  end
end
