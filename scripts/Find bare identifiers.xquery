declare namespace marc="http://www.loc.gov/MARC21/slim";

declare variable $doc := "file:/Users/trondaal/GitHub/LRMData/mrc/bringsv%C3%A6rd.bibsys.xml";

declare variable $aut := map:merge(for $person in doc($doc)//*:datafield[@tag=('100', '600', '700', '110', '610', '710','111', '611', '711')][*:subfield[@code = '0' and starts-with(., '(NO-TrBIB)')]]
group by $name := string-join($person/*:subfield[@code=('a', 'b')], ' - ')
order by count(distinct-values($person/*:subfield[@code='0'])) descending
return map{$name : distinct-values($person/*:subfield[@code='0'])});


for $person in doc($doc)//*:datafield[@tag=('100', '600', '700', '800', '110', '610', '710', '810', '111', '611', '711', '811')]
where not($person/*:subfield[@code = '0' and starts-with(., '(NO-TrBIB)')])
let $id := $aut($person/*:subfield[@code = 'a'])
order by $person/*:subfield[@code='a']
(:return if ($id ne '') then ()  else $person/*:subfield[@code='a']:)
return if ($id ne '') then insert node <marc:subfield code="0">{$id}</marc:subfield> into $person else ()