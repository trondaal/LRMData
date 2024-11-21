declare variable $data336 :=  <datafield tag="336" ind1=" " ind2=" ">
                            <subfield code="a">tekst</subfield>
                            <subfield code="0">http://rdaregistry.info/termList/RDAContentType/1020</subfield>
                            <subfield code="2">rdaco</subfield>
                            </datafield>;
                            
declare variable $data337 :=  <datafield tag="337" ind1=" " ind2=" ">
                    <subfield code="a">uformidlet</subfield>
                    <subfield code="0">http://rdaregistry.info/termList/RDAMediaType/1007</subfield>
                    <subfield code="2">rdamt</subfield>
                </datafield>;
                
declare variable $data338 :=  <datafield tag="338" ind1=" " ind2=" ">
                    <subfield code="a">bind</subfield>
                    <subfield code="0">http://rdaregistry.info/termList/RDACarrierType/1049</subfield>
                    <subfield code="2">rdact</subfield>
                </datafield>;

for $record in doc("../xml/vbinf6000-eksempler/karin.fossum.bibsys.all.xml")//*:record[not(*:datafield[@tag="336"]) and *:datafield[@tag="300"]]
return insert node $data336 after $record/*:datafield[@tag="300"]