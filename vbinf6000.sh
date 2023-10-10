#!/bin/sh

echo "Creating xslt conversion for lrm"
java -cp "../marc2entities/jar/saxon/saxon9he.jar"  net.sf.saxon.Transform -xsl:"../marc2entities/xslt/make.xslt" -s:"conversionrules.xml" -o:"marc2lrm.xslt"

echo "Running transformation and reports for all"
FILES="./vbinf6000/xml/*.xml"
for f in $FILES
do
    base="${f##*/}"
    rdf="./vbinf6000/rdf/${base%xml}rdf"
    stats="./vbinf6000/txt/${base%xml}txt"
    echo "Processing $f to $rdf"
    java -cp "saxon9he.jar" net.sf.saxon.Transform -xsl:marc2lrm.xslt -s:"$f" -o:"$rdf"
    echo "Processing $f to $stats"
    java -cp "saxon9he.jar" net.sf.saxon.Transform -xsl:report.xslt -s:"$f" -o:"$stats"
done
 