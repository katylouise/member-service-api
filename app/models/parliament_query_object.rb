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

  def self.next_parliament(id)
    "PREFIX : <http://id.ukpds.org/schema/>
CONSTRUCT {
    ?nextParliament
        a :ParliamentPeriod .
}
WHERE {
    BIND(<#{DATA_URI_PREFIX}/#{id}> AS ?parliament)

    ?parliament :parliamentPeriodHasImmediatelyFollowingParliamentPeriod ?nextParliament .
}"
  end

  def self.previous_parliament(id)
    "PREFIX : <http://id.ukpds.org/schema/>
CONSTRUCT {
    ?previousParliament
        a :ParliamentPeriod .
}
WHERE {
    BIND(<#{DATA_URI_PREFIX}/#{id}> AS ?parliament)

    ?parliament :parliamentPeriodHasImmediatelyPreviousParliamentPeriod ?previousParliament .
}"
  end

  def self.members(id)
    "PREFIX : <http://id.ukpds.org/schema/>
CONSTRUCT {
    ?person
        a :Person ;
        :personGivenName ?givenName ;
        :personFamilyName ?familyName ;
        <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs ;
        <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs ;
        :memberHasIncumbency ?seatIncumbency ;
        :partyMemberHasPartyMembership ?partyMembership .
   ?seatIncumbency
        a :SeatIncumbency ;
        :seatIncumbencyHasHouseSeat ?houseSeat ;
        :incumbencyEndDate ?seatIncumbencyEndDate .
    ?houseSeat
        a :HouseSeat ;
        :houseSeatHasHouse ?house ;
        :houseSeatHasConstituencyGroup ?constituencyGroup .
   ?constituencyGroup
        a :ConstituencyGroup;
        :constituencyGroupName ?constituencyName .
    ?partyMembership
        a :PartyMembership ;
        :partyMembershipHasParty ?party ;
        :partyMembershipEndDate ?partyMembershipEndDate .
    ?party
        a :Party ;
        :partyName ?partyName .
     ?parliament
         a :ParliamentPeriod ;
         :parliamentPeriodStartDate ?parliamentStartDate ;
         :parliamentPeriodEndDate ?parliamentEndDate ;
         :parliamentPeriodNumber ?parliamentNumber .
    _:x :value ?firstLetter .
}
WHERE {
    { SELECT * WHERE {
        BIND(<#{DATA_URI_PREFIX}/#{id}> AS ?parliament)
        ?parliament
            a :ParliamentPeriod ;
            :parliamentPeriodStartDate ?parliamentStartDate ;
            :parliamentPeriodNumber ?parliamentNumber .
        OPTIONAL { ?parliament :parliamentPeriodEndDate ?parliamentEndDate . }

        OPTIONAL {
            ?parliament :parliamentPeriodHasSeatIncumbency ?seatIncumbency .
            ?seatIncumbency :incumbencyHasMember ?person ;
                            :seatIncumbencyHasHouseSeat ?houseSeat .
            OPTIONAL { ?seatIncumbency :incumbencyEndDate ?seatIncumbencyEndDate . }
            ?houseSeat :houseSeatHasConstituencyGroup ?constituencyGroup .
            ?constituencyGroup :constituencyGroupName ?constituencyName .

            OPTIONAL { ?person :personGivenName ?givenName . }
            OPTIONAL { ?person :personFamilyName ?familyName . }
            OPTIONAL { ?person <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs } .
            ?person <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs .

            OPTIONAL {
                ?person :partyMemberHasPartyMembership ?partyMembership .
                FILTER NOT EXISTS { ?partyMembership a :PastPartyMembership . }
                OPTIONAL { ?partyMembership :partyMembershipEndDate ?partyMembershipEndDate . }
                ?partyMembership :partyMembershipHasParty ?party .
                ?party :partyName ?partyName .
        	}
        }
    }
}
UNION {
    SELECT DISTINCT ?firstLetter WHERE {
        BIND(<#{DATA_URI_PREFIX}/#{id}> AS ?parliament)

        ?parliament a :ParliamentPeriod ;
        			:parliamentPeriodHasSeatIncumbency ?seatIncumbency .
        ?seatIncumbency :incumbencyHasMember ?person .
        ?person <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs .
        BIND(ucase(SUBSTR(?listAs, 1, 1)) as ?firstLetter)
    }
   }
}"
  end

  def self.members_letters(id, letter)
    "PREFIX : <http://id.ukpds.org/schema/>
CONSTRUCT {
    ?person
        a :Person ;
        :personGivenName ?givenName ;
        :personFamilyName ?familyName ;
        <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs ;
        <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs ;
        :memberHasIncumbency ?seatIncumbency ;
        :partyMemberHasPartyMembership ?partyMembership .
   ?seatIncumbency
        a :SeatIncumbency ;
        :seatIncumbencyHasHouseSeat ?houseSeat ;
        :incumbencyEndDate ?seatIncumbencyEndDate .
    ?houseSeat
        a :HouseSeat ;
        :houseSeatHasHouse ?house ;
        :houseSeatHasConstituencyGroup ?constituencyGroup .
   ?constituencyGroup
        a :ConstituencyGroup;
        :constituencyGroupName ?constituencyName .
    ?partyMembership
        a :PartyMembership ;
        :partyMembershipHasParty ?party ;
        :partyMembershipEndDate ?partyMembershipEndDate .
    ?party
        a :Party ;
        :partyName ?partyName .
     ?parliament
         a :ParliamentPeriod ;
         :parliamentPeriodStartDate ?parliamentStartDate ;
         :parliamentPeriodEndDate ?parliamentEndDate ;
         :parliamentPeriodNumber ?parliamentNumber .
    _:x :value ?firstLetter .
}
WHERE {
    { SELECT * WHERE {
        BIND(<#{DATA_URI_PREFIX}/#{id}> AS ?parliament)
        ?parliament
            a :ParliamentPeriod ;
            :parliamentPeriodStartDate ?parliamentStartDate ;
            :parliamentPeriodNumber ?parliamentNumber .
        OPTIONAL { ?parliament :parliamentPeriodEndDate ?parliamentEndDate . }

        OPTIONAL {
            ?parliament :parliamentPeriodHasSeatIncumbency ?seatIncumbency .
            ?seatIncumbency :incumbencyHasMember ?person ;
                            :seatIncumbencyHasHouseSeat ?houseSeat .
            OPTIONAL { ?seatIncumbency :incumbencyEndDate ?seatIncumbencyEndDate . }
            ?houseSeat :houseSeatHasConstituencyGroup ?constituencyGroup .
            ?constituencyGroup :constituencyGroupName ?constituencyName .

            OPTIONAL { ?person :personGivenName ?givenName . }
            OPTIONAL { ?person :personFamilyName ?familyName . }
            OPTIONAL { ?person <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs } .
            ?person <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs .

            OPTIONAL {
                ?person :partyMemberHasPartyMembership ?partyMembership .
                FILTER NOT EXISTS { ?partyMembership a :PastPartyMembership . }
                OPTIONAL { ?partyMembership :partyMembershipEndDate ?partyMembershipEndDate . }
                ?partyMembership :partyMembershipHasParty ?party .
                ?party :partyName ?partyName .
        	}
        FILTER STRSTARTS(LCASE(?listAs), LCASE(\"#{letter}\"))
        }
    }
}
UNION {
    SELECT DISTINCT ?firstLetter WHERE {
        BIND(<#{DATA_URI_PREFIX}/#{id}> AS ?parliament)

        ?parliament a :ParliamentPeriod ;
        			:parliamentPeriodHasSeatIncumbency ?seatIncumbency .
        ?seatIncumbency :incumbencyHasMember ?person .
        ?person <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs .
        BIND(ucase(SUBSTR(?listAs, 1, 1)) as ?firstLetter)
    }
  }
}"
  end

  def self.members_a_z_letters(id)
    "PREFIX : <http://id.ukpds.org/schema/>
CONSTRUCT {
    _:x :value ?firstLetter .
}
WHERE {
    SELECT DISTINCT ?firstLetter WHERE {
        BIND(<#{DATA_URI_PREFIX}/#{id}> AS ?parliament)

        ?parliament a :ParliamentPeriod ;
        			:parliamentPeriodHasSeatIncumbency ?seatIncumbency .
        ?seatIncumbency :incumbencyHasMember ?person .
        ?person <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs .
        BIND(ucase(SUBSTR(?listAs, 1, 1)) as ?firstLetter)
    }
}"
  end
end