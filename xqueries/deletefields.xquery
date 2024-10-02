for $datafield in doc("../xml/vbinf6000-eksempler/karin.fossum.xml")//*:datafield[@tag="035" or @tag > "850"]
return delete nodes $datafield