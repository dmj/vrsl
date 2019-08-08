publish: docs/index.html docs/figure-01.svg docs/vrsl.rdf docs/vrsl.rng docs/vrsl.rnc

docs/index.html: source/specification.xml source/specification.rdf source/vrsl.rnc
	calabash -o docs/index.html src/main/xproc/publish.xpl

docs/vrsl.rdf: source/specification.rdf
	cp source/specification.rdf docs/vrsl.rdf

docs/figure-01.svg:
	cp source/figure-01.svg docs/figure-01.svg

docs/vrsl.rnc: source/vrsl.rnc
	cp source/vrsl.rnc docs/vrsl.rnc

docs/vrsl.rng: source/vrsl.rng
	cp source/vrsl.rng docs/vrsl.rng

source/vrsl.rng: source/specification.rdf
	saxon9-transform -xsl:src/main/xslt/ontology2rng.xsl -o:source/vrsl.rng source/specification.rdf

source/vrsl.rnc: source/vrsl.rng
	trang -I rng -O rnc source/vrsl.rng source/vrsl.rnc

.PHONY: clean
clean:
	rm -f docs/index.html
	rm -f docs/vrsl.*
	rm -f docs/figure-01.svg
	rm -f source/vrsl.rng
	rm -f source/vrsl.rnc
