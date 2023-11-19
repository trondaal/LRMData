MATCH (n:Resource)
DETACH DELETE n;

MATCH (n:Concept)
DETACH DELETE n;

DROP INDEX expressions;
DROP INDEX works;
DROP INDEX resource_uri;

CREATE INDEX resource_uri FOR (n:Resource) ON n.uri;
CREATE FULLTEXT INDEX expressions FOR (n:Expression) ON EACH [n.title, n.titles, n.titlevariant, n.titlepreferred, n.contentsnote, n.names, n.form, n.types, n.uris, n.ids, n.language, n.content];
CREATE FULLTEXT INDEX works FOR (n:Work) ON EACH [n.title, n.titles, n.titlevariant, n.titlepreferred, n.names, n.types, n.form];

WITH "entities.json" AS url
CALL apoc.load.json(url) YIELD value
UNWIND value.results.bindings AS e
WITH e.entity.value as u, e.label.value as l
CALL apoc.merge.node(["Resource", l], {uri: u})
YIELD node
RETURN node;

WITH "concepts.json" AS url
CALL apoc.load.json(url) YIELD value
UNWIND value.results.bindings AS e
WITH e.concept.value as u, e.label.value as l
CALL apoc.merge.node(["Concept"], {uri: u, label: l})
YIELD node
RETURN node;

WITH "types.json" AS url
CALL apoc.load.json(url) YIELD value
UNWIND value.results.bindings AS e
WITH e.s.value as source, e.p.value as property, e.l.value as label, e.o.value as object
MATCH
  (s:Resource {uri: source}),
  (o:Concept {uri: object})
CALL apoc.merge.relationship(s, label,{type: property}, {}, o, {}) yield rel
RETURN rel;

WITH "properties.json" AS url
CALL apoc.load.json(url) YIELD value
UNWIND value.results.bindings AS e
WITH e.entity.value as u, e.label.value as l, e.value.value as v
MERGE (x:Resource {uri: u})
WITH x, l, v
CALL apoc.create.setProperty(x, l, v)
YIELD node
RETURN node;

WITH "form.json" AS url
    CALL apoc.load.json(url) YIELD value
    UNWIND value.results.bindings AS e
    WITH e.entity.value as u, e.label.value as l, e.value.value as v
        MERGE (x:Resource {uri: u})
        WITH x, l, v
            CALL apoc.create.setProperty(x, l, v)
            YIELD node
RETURN node;

WITH "basicrels.json" AS url
CALL apoc.load.json(url) YIELD value
UNWIND value.results.bindings AS e
WITH e.s.value as source, e.l.value as r, e.o.value as object
MATCH
  (s:Resource {uri: source}),
  (o:Resource {uri: object})
CALL apoc.merge.relationship(s, r,{}, {}, o, {}) yield rel
RETURN rel;

WITH "agentrels.json" AS url
CALL apoc.load.json(url) YIELD value
UNWIND value.results.bindings AS e
WITH e.s.value as source, e.p.value as property, e.l.value as label, e.o.value as object
MATCH
  (s:Resource {uri: source}),
  (o:Resource {uri: object})
  CALL apoc.create.relationship(s, "CREATOR",{type: property, role: label}, o) yield rel
RETURN rel;

WITH "subjectrels.json" AS url
CALL apoc.load.json(url) YIELD value
UNWIND value.results.bindings AS e
WITH e.s.value as source, e.p.value as property, e.l.value as label, e.o.value as object
MATCH
  (s:Resource {uri: source}),
  (o:Resource {uri: object})
  CALL apoc.create.relationship(s, "SUBJECT",{type: property, role: label}, o) yield rel
RETURN rel;

WITH "partofrels.json" AS url
CALL apoc.load.json(url) YIELD value
UNWIND value.results.bindings AS e
WITH e.s.value as source, e.p.value as property, e.l.value as label, e.o.value as object
MATCH
  (s:Resource {uri: source}),
  (o:Resource {uri: object})
  CALL apoc.create.relationship(s, "PARTOF",{type: property, role: label}, o) yield rel
RETURN rel;

WITH "horisontalrelationships.json" AS url
CALL apoc.load.json(url) YIELD value
UNWIND value.results.bindings AS e
WITH e.s.value as source, e.p.value as property, e.l.value as label, e.o.value as object
MATCH
  (s:Resource {uri: source}),
  (o:Resource {uri: object})
  CALL apoc.create.relationship(s, "RELATED",{type: property, role: label}, o) yield rel
RETURN rel;

//WITH "expressionrels.json" AS url
//CALL apoc.load.json(url) YIELD value
//UNWIND value.results.bindings AS e
//WITH e.s.value as source, e.p.value as property, e.l.value as label, e.o.value as object
//MATCH
//  (s:Resource {uri: source}),
//  (o:Resource {uri: object})
//  CALL apoc.create.relationship(s, "RELATED",{type: property, role: label}, o) yield rel
//RETURN rel;

WITH "labels.json" AS url
CALL apoc.load.json(url) YIELD value
UNWIND value.results.bindings AS e
WITH e.subject.value as s, e.label.value as l
MERGE (x:Resource {uri: s})
WITH x, l
CALL apoc.create.setProperty(x, "label", l)
YIELD node
RETURN node;

MATCH (r:Resource)
SET r += {titles: '', names: '', types: '', uris: '', ids: '', language: '', content: ''};

//UPDATE FIELDS FOR FULLTEXT INDEXING OF NODES

//NAMES
MATCH (e:Expression)-[:CREATOR]-(a:Agent) where a.name IS NOT NULL
set e.names = e.names + a.name + " : ";

MATCH (e:Expression)-[:REALIZES]-(w:Work)-[:CREATOR]-(a:Agent) where a.name IS NOT NULL
set e.names = e.names + a.name + " : ";

MATCH (e:Expression)-[:EMBODIES]-(m:Manifestation)-[:CREATOR]-(a:Agent) where a.name IS NOT NULL
set e.names = e.names + a.name + " : ";

MATCH (e:Expression)-[:REALIZES]-(w:Work)-[:SUBJECT]-(a:Agent) where a.name IS NOT NULL
set e.names = e.names + a.name + " : ";

MATCH (e:Expression)-[:REALIZES]-(w:Work)-[:SUBJECT]-(a:Agent) where a.variantname IS NOT NULL
set e.names = e.names + a.variantname + " : ";

MATCH (e:Expression)-[:REALIZES]-(w:Work)-[:RELATED]->(:Work)-[:CREATOR]-(a:Agent) where a.name IS NOT NULL
set e.names = e.names + a.name + " : ";

MATCH (e:Expression)-[:REALIZES]-(w:Work)-[:PARTOF]-(:Work)-[:CREATOR]-(a:Agent) where a.name IS NOT NULL
set e.names = e.names + a.name + " : ";

MATCH (e:Expression)-[:PARTOF]-(:Expression)-[:CREATOR]-(a:Agent) where a.name IS NOT NULL
set e.names = e.names + a.name + " : ";

MATCH (e:Expression)-[:RELATED]-(:Expression)-[:CREATOR]-(a:Agent) where a.name IS NOT NULL
set e.names = e.names + a.name + " : ";


//TITLES
MATCH (e:Expression)-[:REALIZES]-(w:Work) where w.title IS NOT NULL
set e.titles = e.titles + w.title + " : ";

MATCH (e:Expression)-[:REALIZES]-(w:Work) where w.name IS NOT NULL
set e.names = e.names + w.name + " : ";

//MATCH (e:Expression)-[:EMBODIES]-(m:Manifestation) where m.title IS NOT NULL
//set e.titles = e.titles + m.title + " : ";

//MATCH (e:Expression)-[:EMBODIES]-(m:Manifestation) where m.subtitle IS NOT NULL
//set e.titles = e.titles + m.subtitle + " : ";

//MATCH (e:Expression)-[:EMBODIES]-(m:Manifestation) where m.part IS NOT NULL
//set e.titles = e.titles + m.part + " : ";

//MATCH (e:Expression)-[:EMBODIES]-(m:Manifestation) where m.contentsnote IS NOT NULL
//set e.titles = e.titles + m.contentsnote + " : ";

MATCH (from:Expression)-[:PARTOF]-(to:Expression) where to.title IS NOT NULL
set from.titles = from.titles + to.title + " : ";

MATCH (from:Expression)-[:RELATED]-(to:Expression) where to.title IS NOT NULL
set from.titles = from.titles + to.title + " : ";

MATCH (e:Expression)-[:REALIZES]-(:Work)-[:SUBJECT]->(w:Work) where w.title IS NOT NULL
set e.titles = e.titles + w.title + " : ";

MATCH (e:Expression)-[:REALIZES]-(:Work)-[:RELATED]->(w:Work) where w.title IS NOT NULL
set e.titles = e.titles + w.title + " : ";

MATCH (e:Expression)-[:REALIZES]-(:Work)-[:PARTOF]-(w:Work) where w.title IS NOT NULL
set e.titles = e.titles + w.title + " : ";


//FORM, TYPE AND LANGUAGE
MATCH (e:Expression)-[:REALIZES]-(w:Work) where w.form IS NOT NULL
set e.types = e.types + w.form + " : ";

MATCH (e:Expression)-[:LANGUAGE]-(c:Concept) where c.label IS NOT NULL
set e.language = e.language + c.label + " : ";

MATCH (e:Expression)-[:CONTENT]-(c:Concept) where c.label IS NOT NULL
set e.content = e.content + c.label + " : ";

//URIs
MATCH (e:Expression) where e.uri IS NOT NULL
set e.uris = e.uris + e.uri + " ";

MATCH (e:Expression)-[:REALIZES]-(w:Work) where w.uri IS NOT NULL
set e.uris = e.uris + w.uri + " ";

MATCH (e:Expression)-[:CREATOR]-(a:Agent) where a.uri IS NOT NULL
set e.uris = e.uris + a.uri + " : ";

MATCH (e:Expression)-[:REALIZES]-(w:Work)-[:CREATOR]-(a:Agent) where a.uri IS NOT NULL
set e.uris = e.uris + a.uri + " : ";

//Identifiers for expressions
MATCH (e:Expression)
set e.id = "E" + ID(e);
MATCH (e:Expression)
set e.ids = e.ids +  e.id  + " ";

MATCH (w:Work)
set w.id = "W" + ID(w);
MATCH (e:Expression)-[:REALIZES]-(w:Work)
set e.ids = e.ids + w.id + " ";

MATCH (a:Agent)
set a.id = "A" + ID(a);
MATCH (e:Expression)-[:CREATOR]-(a:Agent)
set e.ids = e.ids + a.id + " : ";
MATCH (e:Expression)-[:REALIZES]-(w:Work)-[:CREATOR]-(a:Agent)
set e.ids = e.ids + a.id + " : ";


//Set random int on expressions for random sorting
MATCH (e:Expression)
set e.random = toInteger(rand() * (1000));

//NAMES FOR INDEXING WORKS
MATCH (w:Work)-[:CREATOR]-(a:Agent) where a.name IS NOT NULL
WITH w, a,
CASE
    WHEN w.names IS NULL then a.name
    ELSE w.names + " : " + a.name
END AS names
set w.names = names;

MATCH (w:Work)<-[:REALIZES]-(e:Expression)-[:CREATOR]-(a:Agent) where a.name IS NOT NULL
WITH w, a,
CASE
    WHEN w.names IS NULL then a.name
    ELSE w.names + " : " + a.name
END AS names
set w.names = names;

MATCH (w:Work)<-[:REALIZES]-(e:Expression)-[:EMBODIES]-(m:Manifestation)-[:CREATOR]-(a:Agent) where a.name IS NOT NULL
WITH w, a,
CASE
    WHEN w.names IS NULL then a.name
    ELSE w.names + " : " + a.name
END AS names
set w.names = names;

MATCH (w:Work)-[:SUBJECT]-(a:Agent) where a.name IS NOT NULL
WITH w, a,
CASE
    WHEN w.names IS NULL then a.name
    ELSE w.names + " : " + a.name
END AS names
set w.names = names;

MATCH (w:Work)-[:RELATED]->(:Work)-[:CREATOR]-(a:Agent) where a.name IS NOT NULL
WITH w, a,
CASE
    WHEN w.names IS NULL then a.name
    ELSE w.names + " : " + a.name
END AS names
set w.names = names;

MATCH (w:Work)-[:PARTOF]-(:Work)-[:CREATOR]-(a:Agent) where a.name IS NOT NULL
WITH w, a,
CASE
    WHEN w.names IS NULL then a.name
    ELSE w.names + " : " + a.name
END AS names
set w.names = names;

//TITLES FOR INDEXING WORKS
MATCH (w:Work)<-[:REALIZES]-(e:Expression ) where e.titlepreferred IS NOT NULL
WITH e,w,
CASE
    WHEN w.titles IS NULL then e.titlepreferred
    ELSE w.titles + " : " + e.titlepreferred
END AS title
set w.titles = title;

MATCH (w:Work)<-[:REALIZES]-(e:Expression) where e.title IS NOT NULL
WITH e,w,
CASE
    WHEN w.titles IS NULL then e.title
    ELSE w.titles + " : " + e.title
END AS title
set w.titles = title;

MATCH (w:Work)<-[:REALIZES]-(e:Expression) where e.titlealternative IS NOT NULL
WITH e,w,
CASE
    WHEN w.titles IS NULL then e.titlealternative
    ELSE w.titles + " : " + e.titlealternative
END AS title
set w.titles = title;

MATCH (w:Work)<-[:REALIZES]-(e:Expression)-[:EMBODIES]-(m:Manifestation) where m.title IS NOT NULL
WITH m,w,
CASE
    WHEN w.titles IS NULL then m.title
    ELSE w.titles + " : " + m.title
END AS title
set w.titles = title;

MATCH (w:Work)<-[:REALIZES]-(e:Expression)-[:EMBODIES]-(m:Manifestation) where m.subtitle IS NOT NULL
WITH m,w,
CASE
    WHEN w.titles IS NULL then m.subtitle
    ELSE w.titles + " : " + m.subtitle
END AS title
set w.titles = title;

MATCH (w:Work)<-[:REALIZES]-(e:Expression)-[:EMBODIES]-(m:Manifestation) where m.part IS NOT NULL
WITH m,w,
CASE
    WHEN w.titles IS NULL then m.part
    ELSE w.titles + " : " + m.part
END AS title
set w.titles = title;

MATCH (w:Work)-[:SUBJECT]->(w2:Work)  where w2.title IS NOT NULL
WITH w,w2,
CASE
    WHEN w.titles IS NULL then w2.title
    ELSE w.titles + " : " + w2.title
END AS title
set w.titles = title;


MATCH (w:Work)-[:RELATED]->(w2:Work) where w2.title IS NOT NULL
WITH w,w2,
CASE
    WHEN w.titles IS NULL then w2.title
    ELSE w.titles + " : " + w2.title
END AS title
set w.titles = title;

MATCH (w:Work)-[:PARTOF]-(w2:Work) where w2.title IS NOT NULL
WITH w,w2,
CASE
    WHEN w.titles IS NULL then w2.title
    ELSE w.titles + " : " + w2.title
END AS title
set w.titles = title  + " : ";