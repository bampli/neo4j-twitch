(:User {id: uuid})-[:HAS_SUBSCRIPTION]-->(:Subscription {expiresAt >= datetime()})-[:FOR_PACKAGE]-->(:Package)-[:PROVIDE_ACCESS_TO]-->(:Genre)<--[:IN_GENRE]-(:Movie)
+
(:User {id: uuid})-[:HAS_SUBSCRIPTION]-->(:Subscription {expiresAt >= datetime()})-[:FOR_PACKAGE]-->(:Package)-[:PROVIDE_ACCESS_TO]-->(:ProductionCompany)<--[:PRODUCED_BY]-(:Movie)
=
(:User {id: uuid})-[:HAS_SUBSCRIPTION]-->(:Subscription {expiresAt >= datetime()})-[:FOR_PACKAGE]-->(:Package)-[:PROVIDE_ACCESS_TO]-->()<--[:IN_GENRE|PRODUCED_BY]-(:Movie)

// Select some ProductionCompany
MATCH (p:ProductionCompany)<-[:PRODUCED_BY]-(m)-[:IN_GENRE]->(g)
WITH p, collect(g.name) AS genres, count(DISTINCT m) AS movieCount
WHERE none(g in genres WHERE g in split("Animation|Comedy|Family|Adventure", "|")) RETURN * LIMIT 10

// Bronze package also offer access to movies from selected ProductionCompany
MATCH (p:Package {id:2})
MATCH (c:ProductionCompany) WHERE c.id IN [915, 11583, 11584,10104,15547]
CREATE (p)-[:PROVIDES_ACCESS_TO]->(c)

// User for Bronze
MATCH (p:Package{id: 2})

CREATE(u:User {
    id: 'test',
    email: 'bronze.user@neoflix.com',
    firstname: 'Test',
    lastname: 'User'
})

CREATE (u)-[:HAS_SUBSCRIPTION]->(s:Subscription{
    id: 'test',
    expiresAt: datetime() + duration('P2D')
})-[:FOR_PACKAGE]->(p)

RETURN *

// User2
MATCH (p:Package{id: 2})

CREATE(u:User {
    id: 'test-u2',
    email: 'bronze2.user@neoflix.com',
    firstname: 'Test2',
    lastname: 'User2'
})

CREATE (u)-[:HAS_SUBSCRIPTION]->(s:Subscription{
    id: 'test-s2',
    expiresAt: datetime() + duration('P2D')
})-[:FOR_PACKAGE]->(p)

RETURN *

// Check films that Bronze user can watch
MATCH(u:User {id: 'test'})-[:HAS_SUBSCRIPTION]->(s)-[:FOR_PACKAGE]->(p)
WHERE s.expiresAt >= datetime()

MATCH(m:Movie)
WITH u, s, p, m ORDER BY rand() LIMIT 10
RETURN
    m.id,
    m.title,
    exists ( (m)-[:IN_GENRE|PRODUCED_BY]->()<-[:PROVIDES_ACCESS_TO]-(p))
