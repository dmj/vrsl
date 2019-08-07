<xsl:transform version="2.0"
               xpath-default-namespace="http://docbook.org/ns/docbook"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output method="html" version="5" indent="yes"/>

  <!-- Convert specification to HTML output -->
  <xsl:template match="article">
    <html>
      <head>
        <xsl:apply-templates select="info" mode="head"/>
        <link rel="stylesheet" href="style.css" type="text/css"/>
        <link rel="stylesheet" href="highlight/styles/default.css"/>
        <script src="highlight/highlight.pack.js"></script>
        <script>hljs.initHighlightingOnLoad();</script>
      </head>
      <body>
        <div class="draft">
          <p>Editor's Draft</p>
        </div>
        <xsl:apply-templates select="info"/>
        <xsl:apply-templates select="section | appendix"/>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="section | appendix">
    <div>
      <xsl:apply-templates select="@* | node()"/>
    </div>
  </xsl:template>

  <xsl:template match="@xml:id">
    <xsl:attribute name="id" select="."/>
  </xsl:template>

  <xsl:template match="title">
    <xsl:element name="h{1 + count(ancestor::section)}">
      <xsl:value-of select="."/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="info/title">
    <h1>
      <xsl:apply-templates/>
      <xsl:if test="../subtitle">
        <br/>
        <small>
          <xsl:apply-templates select="../subtitle/node()"/>
        </small>
      </xsl:if>
    </h1>
  </xsl:template>
  <xsl:template match="info/subtitle"/>

  <xsl:template match="para">
    <p>
      <xsl:apply-templates/>
    </p>
  </xsl:template>

  <xsl:template match="authorgroup">
    <address>
      <xsl:for-each select="author">
        <p>
          <xsl:value-of select="personname"/>
        </p>
      </xsl:for-each>
    </address>
  </xsl:template>

  <xsl:template match="itemizedlist">
    <ul>
      <xsl:apply-templates/>
    </ul>
  </xsl:template>

  <xsl:template match="variablelist">
    <dl>
      <xsl:apply-templates/>
    </dl>
  </xsl:template>

  <xsl:template match="varlistentry/term">
    <dt><xsl:apply-templates/></dt>
  </xsl:template>

  <xsl:template match="varlistentry/listitem">
    <dd><xsl:apply-templates/></dd>
  </xsl:template>

  <xsl:template match="itemizedlist/listitem">
    <li>
      <xsl:apply-templates/>
    </li>
  </xsl:template>

  <xsl:template match="link[@linkend]">
    <a href="#{@linkend}">
      <xsl:apply-templates/>
    </a>
  </xsl:template>

  <xsl:template match="figure">
    <figure>
      <xsl:apply-templates select="* except title"/>
      <xsl:apply-templates select="title"/>
    </figure>
  </xsl:template>

  <xsl:template match="figure/title">
    <figcaption>
      <xsl:apply-templates/>
    </figcaption>
  </xsl:template>

  <xsl:template match="imageobject/imagedata[@fileref]">
    <img src="{@fileref}"/>
  </xsl:template>

  <xsl:template match="example">
    <samp>
      <p><xsl:apply-templates select="title/node()"/></p>
      <pre><code class="programlisting/@language"><xsl:apply-templates select="programlisting/node()"/></code></pre>
    </samp>
  </xsl:template>

  <xsl:template match="informalexample">
    <div class="example">
      <em>Example:</em>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="tag | uri">
    <code><xsl:apply-templates/></code>
  </xsl:template>

  <xsl:template match="title"  mode="head">
    <title><xsl:value-of select="."/></title>
  </xsl:template>

  <xsl:template match="info">
    <xsl:apply-templates select="title"/>
    <xsl:apply-templates select="* except (title, subtitle)"/>
  </xsl:template>

  <xsl:template match="author" mode="head">
    <meta name="Author" content="{normalize-space(.)}"/>
  </xsl:template>

  <xsl:template match="text()" mode="head"/>

</xsl:transform>
