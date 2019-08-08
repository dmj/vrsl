<p:declare-step name="main" version="1.0"
                xmlns:db="http://docbook.org/ns/docbook"
                xmlns:p="http://www.w3.org/ns/xproc">

  <p:output port="result"/>

  <p:serialization port="result" indent="true" method="html" version="5"/>

  <p:xslt name="ontology2db">
    <p:input port="source">
      <p:document href="../../../source/specification.rdf"/>
    </p:input>
    <p:input port="stylesheet">
      <p:document href="../xslt/ontology2db.xsl"/>
    </p:input>
    <p:input port="parameters">
      <p:empty/>
    </p:input>
  </p:xslt>

  <p:load href="../../../source/specification.xml" name="specification"/>

  <p:xinclude name="process-includes">
    <p:input port="source">
      <p:pipe step="specification" port="result"/>
    </p:input>
  </p:xinclude>

  <p:replace match="db:section[@xml:id = 'ontology']" name="insert-ontology">
    <p:input port="source">
      <p:pipe step="process-includes" port="result"/>
    </p:input>
    <p:input port="replacement">
      <p:pipe step="ontology2db" port="result"/>
    </p:input>
  </p:replace>

  <p:xslt name="db2html">
    <p:input port="source">
      <p:pipe step="insert-ontology" port="result"/>
    </p:input>
    <p:input port="stylesheet">
      <p:document href="../xslt/db2html.xsl"/>
    </p:input>
    <p:input port="parameters">
      <p:empty/>
    </p:input>
  </p:xslt>

</p:declare-step>
