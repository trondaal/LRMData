<marc:collection xmlns:marc="http://www.loc.gov/MARC21/slim"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd">{
for $record in //*:record[*:datafield/@tag = '020']
let $isbn := $record/*:datafield[@tag='020'][1]/*:subfield[@code='a'][1]/replace(., '\D', '')
group by $isbn
where count($record) > 1
return if ($record/*:controlfield[@tag='003'] = 'Uk') then $record[*:controlfield[@tag='003'] = 'Uk'] else 
            if ($record/*:controlfield[@tag='003'] = 'UK') then $record[*:controlfield[@tag='003'] = 'UK'] else 
            if ($record/*:controlfield[@tag='003'] = 'UkOxU') then $record[*:controlfield[@tag='003'] = 'UkOxU'] else
            if ($record/*:controlfield[@tag='003'] = 'SpMaBN') then $record[*:controlfield[@tag='003'] = 'SpMaBN'] else
            if ($record/*:controlfield[@tag='003'] = 'BIBSYS') then $record[*:controlfield[@tag='003'] = 'BIBSYS'] else
            if ($record/*:controlfield[@tag='003'] = 'SE-LIBR') then $record[*:controlfield[@tag='003'] = 'SE-LIBR'] else
            if ($record/*:controlfield[@tag='003'] = 'FI_MELINDA') then $record[*:controlfield[@tag='003'] = 'FI_MELINDA'] else
            if ($record/*:controlfield[@tag='003'] = 'SE-LIBR') then $record[*:controlfield[@tag='003'] = 'SE-LIBR'] else ()
}</marc:collection>