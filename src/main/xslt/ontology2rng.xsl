<xsl:transform version="2.0"
               exclude-result-prefixes="fn"
               xpath-default-namespace="http://relaxng.org/ns/structure/1.0"
               xmlns="http://relaxng.org/ns/structure/1.0"
               xmlns:a="http://relaxng.org/ns/compatibility/annotations/1.0"
               xmlns:fn="urn:uuid:a8b57e0e-713b-4c4a-b5d1-8d0abdbe9803"
               xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
               xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
               xmlns:sh="http://www.w3.org/ns/shacl#"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output indent="yes"/>

  <xsl:key name="classes" match="rdfs:Class" use="resolve-uri(@rdf:about, base-uri(@rdf:about))"/>
  <xsl:key name="super" match="rdfs:Class[rdfs:subClassOf]" use="resolve-uri(rdfs:subClassOf/@rdf:resource, base-uri(rdfs:subClassOf/@rdf:resource))"/>

  <xsl:template match="rdf:RDF">
    <grammar datatypeLibrary="http://www.w3.org/2001/XMLSchema-datatypes" ns="https://dmaus.name/ns/vrsl#">
      <a:documentation>Autogenerated from the formal ontology</a:documentation>
      <start>
        <ref name="ValidationSummary"/>
      </start>

      <!-- Grammar rule for any kind of content -->
      <define name="any-content">
        <zeroOrMore>
          <choice>
            <element>
              <anyName/>
              <ref name="any-content"/>
            </element>
            <attribute>
              <anyName/>
            </attribute>
            <text/>
          </choice>
        </zeroOrMore>
      </define>

      <!-- Grammar rule for foreign classes and properties -->
      <define name="foreign-properties">
        <zeroOrMore>
          <element>
            <anyName>
              <except>
                <nsName ns="https://dmaus.name/ns/vrsl#"/>
              </except>
            </anyName>
            <ref name="any-content"/>
          </element>
        </zeroOrMore>
      </define>

      <xsl:variable name="grammar" as="element()*">
        <xsl:apply-templates/>
      </xsl:variable>

      <xsl:apply-templates select="$grammar" mode="post-process"/>

    </grammar>
  </xsl:template>

  <xsl:template match="node() | @*" mode="post-process">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="exactlyOne" mode="post-process">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <xsl:template match="text()"/>

  <xsl:template match="rdfs:Class">
    <xsl:variable name="uri" select="resolve-uri(@rdf:about, base-uri(@rdf:about))"/>
    
    <define name="{fn:pattern-name($uri)}">
      <choice>
        <element name="{fn:element-name($uri)}">
          <interleave>
            <xsl:for-each select="sh:property/sh:PropertyShape">
              <!-- Creates a dummy <exactlyOne> of occurrence {1,1} that is removed in post-process -->
              <xsl:element name="{fn:occurrence-name(.)}">
                <ref name="{fn:pattern-name(resolve-uri(sh:path/@rdf:resource, base-uri(sh:path/@rdf:resource)))}"/>
              </xsl:element>
            </xsl:for-each>
            <ref name="foreign-properties"/>
            <empty/>
          </interleave>
        </element>
        <xsl:for-each select="key('super', $uri)">
          <ref name="{fn:pattern-name(resolve-uri(@rdf:about, base-uri(@rdf:about)))}"/>
        </xsl:for-each>
      </choice>
    </define>
  </xsl:template>

  <xsl:template match="rdfs:Property">
    <define name="{fn:pattern-name(resolve-uri(@rdf:about, base-uri(@rdf:about)))}">
      <element name="{fn:element-name(resolve-uri(@rdf:about, base-uri(@rdf:about)))}">
        <xsl:variable name="range" select="rdfs:range/@rdf:resource"/>

        <xsl:choose>
          <xsl:when test="starts-with($range, 'http://www.w3.org/2001/XMLSchema#')">
            <attribute name="rdf:datatype">
              <value>
                <xsl:value-of select="$range"/>
              </value>
            </attribute>
            <data type="{substring-after($range, '#')}"/>
          </xsl:when>
          <xsl:when test="$range eq 'http://www.w3.org/1999/02/22-rdf-syntax-ns#langString'">
            <interleave>
              <attribute name="xml:lang">
                <data type="language"/>
              </attribute>
              <text/>
            </interleave>
          </xsl:when>
          <xsl:when test="$range and key('classes', resolve-uri($range, base-uri($range)))">
            <ref name="{fn:pattern-name($range)}"/>
          </xsl:when>
          <xsl:otherwise>
            <ref name="any-content"/>
          </xsl:otherwise>
        </xsl:choose>

      </element>
    </define>
  </xsl:template>

  <xsl:function name="fn:element-name" as="xs:string">
    <xsl:param name="uri" as="xs:anyURI"/>
    <xsl:value-of select="substring-after($uri, '#')"/>
  </xsl:function>

  <xsl:function name="fn:pattern-name" as="xs:string">
    <xsl:param name="uri" as="xs:anyURI"/>
    <xsl:value-of select="substring-after($uri, '#')"/>
  </xsl:function>

  <xsl:function  name="fn:occurrence-name" as="xs:string?">
    <xsl:param name="property" as="element(sh:PropertyShape)"/>
    <xsl:variable name="minCount" select="if (exists($property/sh:minCount)) then $property/sh:minCount else 0"/>
    <xsl:variable name="maxCount" select="if (exists($property/sh:maxCount)) then $property/sh:maxCount else 2"/>
    <xsl:choose>
      <xsl:when test="$maxCount = 2 and $minCount = 0">zeroOrMore</xsl:when>
      <xsl:when test="$maxCount = 2 and $minCount = 1">oneOrMore</xsl:when>
      <xsl:when test="$maxCount = 1 and $minCount = 0">optional</xsl:when>
      <xsl:otherwise>exactlyOne</xsl:otherwise>
    </xsl:choose>
  </xsl:function>

</xsl:transform>
