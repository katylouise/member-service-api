class ParliamentQueryObject
  extend QueryObject

  def self.all
    'PREFIX : <http://id.ukpds.org/schema/>
CONSTRUCT {
    ?parliament
        a :ParliamentPeriod ;
        :parliamentPeriodStartDate ?startDate ;
        :parliamentPeriodEndDate ?endDate ;
        :parliamentPeriodNumber ?parliamentNumber .
}
WHERE {
    ?parliament
        a :ParliamentPeriod ;
        :parliamentPeriodStartDate ?startDate ;
        :parliamentPeriodNumber ?parliamentNumber .
    OPTIONAL { ?parliament :parliamentPeriodEndDate ?endDate . }
}'
  end

  def self.current
    'PREFIX : <http://id.ukpds.org/schema/>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
CONSTRUCT {
    ?parliament
        a :ParliamentPeriod .
}
WHERE {
    ?parliament a :ParliamentPeriod ;
                :parliamentPeriodStartDate ?startDate .
    FILTER NOT EXISTS { ?parliament a :PastParliamentPeriod }
    BIND(xsd:dateTime(?startDate) AS ?startDateTime)
    BIND(now() AS ?currentDate)
    FILTER(?startDateTime < ?currentDate)
}'
  end

  def self.previous
    'PREFIX : <http://id.ukpds.org/schema/>
CONSTRUCT {
    ?previousParliament
        a :ParliamentPeriod .
}
WHERE {
    {
        ?parliament a :ParliamentPeriod .
        FILTER NOT EXISTS { ?parliament a :PastParliamentPeriod }
        ?parliament :parliamentPeriodHasImmediatelyPreviousParliamentPeriod ?previousParliament .

    }
    UNION {
        ?parliament a :ParliamentPeriod .
        {  SELECT (max(?parliamentPeriodEndDate) AS ?maxEndDate)
          WHERE {
              ?parliament a :ParliamentPeriod ;
                        :parliamentPeriodEndDate ?parliamentPeriodEndDate .
          }
   		}
        ?parliament :parliamentPeriodEndDate ?maxEndDate .
        BIND(?parliament AS ?previousParliament)
    }
}'
  end

  def self.next
    'PREFIX : <http://id.ukpds.org/schema/>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
CONSTRUCT {
    ?nextParliament
        a :ParliamentPeriod .
}
WHERE {
    ?nextParliament a :ParliamentPeriod ;
                    :parliamentPeriodStartDate ?startDate .
    BIND(now() AS ?currentDate)
    BIND(xsd:dateTime(?startDate) AS ?startDateTime)
    FILTER(?startDateTime > ?currentDate)
}'
  end

  def self.lookup(source, id)
    "PREFIX : <http://id.ukpds.org/schema/>
CONSTRUCT {
    ?parliament a :ParliamentPeriod .
}
WHERE {
    BIND(\"#{id}\" AS ?id)
    BIND(:#{source} AS ?source)
    ?parliament
        a :ParliamentPeriod ;
        ?source ?id .
}"
  end

  def self.find(id)
    "PREFIX : <http://id.ukpds.org/schema/>
CONSTRUCT {
    ?parliament
        a :ParliamentPeriod ;
        :parliamentPeriodStartDate ?startDate ;
        :parliamentPeriodEndDate ?endDate ;
        :parliamentPeriodNumber ?parliamentNumber .
    ?party
        a :Party ;
        :partyName ?partyName ;
        :count ?memberCount .
}
WHERE {
    SELECT ?parliament ?startDate ?endDate ?parliamentNumber ?party ?partyName (COUNT(?member) AS ?memberCount)
    WHERE {
        BIND(<#{DATA_URI_PREFIX}/#{id}> AS ?parliament)
        ?parliament
            a :ParliamentPeriod ;
            :parliamentPeriodStartDate ?startDate ;
            :parliamentPeriodNumber ?parliamentNumber .
            OPTIONAL { ?parliament :parliamentPeriodEndDate ?endDate . }

        OPTIONAL {
            ?parliament :parliamentPeriodHasSeatIncumbency ?seatIncumbency .
            ?seatIncumbency :incumbencyStartDate ?incStartDate ;
           					:incumbencyHasMember ?member .
            OPTIONAL { ?seatIncumbency :incumbencyEndDate ?incumbencyEndDate . }
            ?member :partyMemberHasPartyMembership ?partyMembership .
            ?partyMembership :partyMembershipHasParty ?party ;
                             :partyMembershipStartDate ?pmStartDate .
            OPTIONAL { ?partyMembership :partyMembershipEndDate ?partyMembershipEndDate . }
            ?party :partyName ?partyName .

            BIND(COALESCE(?partyMembershipEndDate,now()) AS ?pmEndDate)
    		BIND(COALESCE(?incumbencyEndDate,now()) AS ?incEndDate)
            FILTER (
                (?pmStartDate <= ?incStartDate && ?pmEndDate > ?incStartDate) ||
                (?pmStartDate >= ?incStartDate && ?pmStartDate < ?incEndDate)
            )
        }
    }
	GROUP BY ?parliament ?startDate ?endDate ?parliamentNumber ?party ?partyName
}"
  end

  def self.members(id)

  end
end