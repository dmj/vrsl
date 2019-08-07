<xsl:transform version="2.0"
               exclude-result-prefixes="#all"
               xpath-default-namespace="http://www.w3.org/2000/01/rdf-schema#"
               xmlns="http://docbook.org/ns/docbook"
               xmlns:sh="http://www.w3.org/ns/shacl#"
               xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
               xmlns:xlink="http://www.w3.org/1999/xlink"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output indent="yes"/>

  <!-- Convert RDF/XML encoded ontology into a DocBook section -->
  <xsl:template match="rdf:RDF">
    <section xml:id="ontology">
      <title>Ontology</title>
      <section>
        <title>Classes</title>
        <xsl:apply-templates select="Class">
          <xsl:sort select="@rdf:about"/>
        </xsl:apply-templates>
      </section>
      <section>
        <title>Properties</title>
        <xsl:apply-templates select="Property">
          <xsl:sort select="@rdf:about"/>
        </xsl:apply-templates>
      </section>
    </section>
  </xsl:template>

  <xsl:template match="Class">
    <xsl:variable name="uri"  select="resolve-uri(@rdf:about, base-uri(.))"/>
    <xsl:variable name="name" select="substring(@rdf:about, 2)"/>
    <section xml:id="{$name}">
      <title><xsl:value-of select="label"/></title>
      <xsl:if test="comment">
        <xsl:for-each select="comment">
          <para><xsl:value-of select="."/></para>
        </xsl:for-each>
      </xsl:if>
      <variablelist>
        <varlistentry>
          <term>URI</term>
          <listitem>
            <para>
              <xsl:value-of select="$uri"/>
            </para>
          </listitem>
        </varlistentry>
        <xsl:if test="subClassOf">
          <varlistentry>
            <term>Subclass of</term>
            <listitem>
              <para>
                <xsl:for-each select="subClassOf">
                  <xsl:sort select="resolve-uri(@rdf:resource, base-uri(.))"/>
                  <xsl:call-template name="reference">
                    <xsl:with-param name="target" select="resolve-uri(@rdf:resource, base-uri(.))"/>
                  </xsl:call-template>
                </xsl:for-each>
              </para>
            </listitem>
          </varlistentry>
        </xsl:if>
        <xsl:if test="sh:property">
          <varlistentry>
            <term>Properties</term>
            <listitem>
              <para>
                <xsl:for-each select="sh:property/sh:PropertyShape">
                  <xsl:sort select="resolve-uri(sh:path/@rdf:resource, base-uri(sh:path))"/>
                  <xsl:if test="position() gt 1">, </xsl:if>
                  <xsl:call-template name="reference">
                    <xsl:with-param name="target" select="resolve-uri(sh:path/@rdf:resource, base-uri(sh:path))"/>
                    <xsl:with-param name="suffix">
                      <xsl:call-template name="property-suffix">
                        <xsl:with-param name="property" select="."/>
                      </xsl:call-template>
                    </xsl:with-param>
                  </xsl:call-template>
                </xsl:for-each>
              </para>
            </listitem>
          </varlistentry>
        </xsl:if>
      </variablelist>
    </section>
  </xsl:template>

  <xsl:template match="Property">
    <xsl:variable name="uri"  select="resolve-uri(@rdf:about, base-uri(.))"/>
    <xsl:variable name="name" select="substring(@rdf:about, 2)"/>
    <section xml:id="{$name}">
      <title><xsl:value-of select="label"/></title>
      <xsl:if test="comment">
        <xsl:for-each select="comment">
          <para><xsl:value-of select="."/></para>
        </xsl:for-each>
      </xsl:if>
      <variablelist>
        <varlistentry>
          <term>URI</term>
          <listitem>
            <para>
              <xsl:value-of select="$uri"/>
            </para>
          </listitem>
        </varlistentry>
        <xsl:if test="domain">
          <varlistentry>
            <term>Domain</term>
            <listitem>
              <para>
                <xsl:call-template name="reference">
                  <xsl:with-param name="target" select="resolve-uri(domain/@rdf:resource, base-uri(domain))"/>
                </xsl:call-template>
              </para>
            </listitem>
          </varlistentry>
        </xsl:if>
        <xsl:if test="range">
          <varlistentry>
            <term>Range</term>
            <listitem>
              <para>
                <xsl:call-template name="reference">
                  <xsl:with-param name="target" select="resolve-uri(range/@rdf:resource, base-uri(range))"/>
                </xsl:call-template>
              </para>
            </listitem>
          </varlistentry>
        </xsl:if>
      </variablelist>
    </section>
  </xsl:template>

  <xsl:template name="property-suffix" as="xs:string?">
    <xsl:param name="property" required="yes" as="element(sh:PropertyShape)"/>
    <xsl:variable name="minCount" select="if (exists(sh:minCount)) then sh:minCount else 0"/>
    <xsl:variable name="maxCount" select="if (exists(sh:maxCount)) then sh:maxCount else 2"/>
    <xsl:choose>
      <xsl:when test="$maxCount = 2 and $minCount = 0">*</xsl:when>
      <xsl:when test="$maxCount = 2 and $minCount = 1">+</xsl:when>
      <xsl:when test="$maxCount = 1 and $minCount = 0">?</xsl:when>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="reference">
    <xsl:param name="target" required="yes" as="xs:string"/>
    <xsl:param name="suffix" required="no"  as="xs:string?"/>
    <xsl:choose>
      <xsl:when test="starts-with($target, 'https://dmaus.name/ns/vrsl#')">
        <link linkend="{substring-after($target, '#')}">
          <xsl:value-of select="substring-after($target, '#')"/>
        </link>
      </xsl:when>
      <xsl:when test="starts-with($target, 'http://www.w3.org/2001/XMLSchema#')">
        <xsl:value-of select="concat('xsd:', substring-after($target, '#'))"/>
      </xsl:when>
      <xsl:when test="starts-with($target, 'http://www.w3.org/1999/02/22-rdf-syntax-ns#')">
        <xsl:value-of select="concat('rdf:', substring-after($target, '#'))"/>
      </xsl:when>
      <xsl:otherwise>
        <link xlink:href="{$target}">
          <xsl:value-of select="$target"/>
        </link>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:value-of select="$suffix"/>
  </xsl:template>

</xsl:transform>
