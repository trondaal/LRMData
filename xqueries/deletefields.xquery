for $datafield in doc("../xml/vbinf6000-eksempler/karin.fossum.bibsys.all.xml")//*:datafield[@tag=("014","015","040", "042", "044", "035", "082", "084") or @tag > "850"]
return delete nodes $datafield