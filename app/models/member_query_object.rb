class MemberQueryObject
  extend QueryObject

  def self.all
    'PREFIX : <http://id.ukpds.org/schema/>
    CONSTRUCT {
    ?houseSeat
        a :HouseSeat ;
        :houseSeatHasConstituencyGroup ?constituencyGroup .
    ?person
        a :Person ;
        :personGivenName ?givenName ;
        :personFamilyName ?familyName ;
        <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs ;
        <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs ;
        :memberHasIncumbency ?incumbency ;
        :partyMemberHasPartyMembership ?partyMembership .
    ?seatIncumbency
        a :SeatIncumbency ;
        :seatIncumbencyHasHouseSeat ?houseSeat ;
        :incumbencyEndDate ?seatIncumbencyEndDate .
    ?houseIncumbency
        a :HouseIncumbency ;
        :incumbencyEndDate ?houseIncumbencyEndDate .
    ?constituencyGroup
        a :ConstituencyGroup ;
        :constituencyGroupName ?constituencyName .
    ?partyMembership
        a :PartyMembership ;
        :partyMembershipEndDate ?partyMembershipEndDate ;
        :partyMembershipHasParty ?party .
    ?party
        a :Party ;
        :partyName ?partyName .
    _:x :value ?firstLetter .
}
WHERE {
    { SELECT * WHERE {
        ?person
            a :Person ;
            :memberHasIncumbency ?incumbency .
        OPTIONAL { ?person :personGivenName ?givenName . }
        OPTIONAL { ?person :personFamilyName ?familyName . }
        OPTIONAL { ?person <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs } .
        ?person <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs .
        {
            ?incumbency a :HouseIncumbency .
            BIND(?incumbency AS ?houseIncumbency)
            OPTIONAL { ?houseIncumbency :incumbencyEndDate ?houseIncumbencyEndDate . }
        }
        UNION {
            ?incumbency a :SeatIncumbency .
            BIND(?incumbency AS ?seatIncumbency)
            ?seatIncumbency :seatIncumbencyHasHouseSeat ?houseSeat .
            OPTIONAL { ?seatIncumbency :incumbencyEndDate ?seatIncumbencyEndDate . }
            OPTIONAL { ?houseSeat :houseSeatHasConstituencyGroup ?constituencyGroup .
                ?constituencyGroup :constituencyGroupName ?constituencyName .
                FILTER NOT EXISTS { ?constituencyGroup a :PastConstituencyGroup . }
            }
        }
        OPTIONAL {
            ?person :partyMemberHasPartyMembership ?partyMembership .
            FILTER NOT EXISTS { ?partyMembership a :PastPartyMembership . }
            OPTIONAL { ?partyMembership :partyMembershipEndDate ?partyMembershipEndDate . }
            ?partyMembership :partyMembershipHasParty ?party .
            ?party :partyName ?partyName .
        }
      }
    }
    UNION {
        SELECT DISTINCT ?firstLetter WHERE {
	        ?incumbency a :Incumbency ;
                        :incumbencyHasMember ?person .
          ?person <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs .

          BIND(ucase(SUBSTR(?listAs, 1, 1)) as ?firstLetter)
        }
      }
}'
  end

  def self.all_by_letter(letter)
    "PREFIX : <http://id.ukpds.org/schema/>
CONSTRUCT {
    ?houseSeat
        a :HouseSeat ;
        :houseSeatHasHouse ?house ;
        :houseSeatHasConstituencyGroup ?constituencyGroup .
    ?person
        a :Person ;
        :personGivenName ?givenName ;
        :personFamilyName ?familyName ;
        <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs ;
        <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs ;
        :memberHasIncumbency ?incumbency ;
        :partyMemberHasPartyMembership ?partyMembership .
    ?seatIncumbency
        a :SeatIncumbency ;
        :seatIncumbencyHasHouseSeat ?houseSeat ;
        :incumbencyEndDate ?seatIncumbencyEndDate .
    ?houseIncumbency
        a :HouseIncumbency ;
        :houseIncumbencyHasHouse ?house ;
        :incumbencyEndDate ?houseIncumbencyEndDate .
    ?house
        a :House ;
        :houseName ?houseName .
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
    _:x :value ?firstLetter .
}
WHERE {
    { SELECT * WHERE {
        ?person a :Person ;
        :memberHasIncumbency ?incumbency .
        OPTIONAL { ?person :personGivenName ?givenName . }
        OPTIONAL { ?person :personFamilyName ?familyName . }
        OPTIONAL { ?person <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs } .
        ?person <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs .
        {
            ?incumbency a :HouseIncumbency .
            BIND(?incumbency AS ?houseIncumbency)
            ?houseIncumbency :houseIncumbencyHasHouse ?house .
            ?house :houseName ?houseName .
            OPTIONAL { ?houseIncumbency :incumbencyEndDate ?houseIncumbencyEndDate . }
        }
        UNION {
            ?incumbency a :SeatIncumbency .
            BIND(?incumbency AS ?seatIncumbency)
            ?seatIncumbency
                :seatIncumbencyHasHouseSeat ?houseSeat .
            OPTIONAL { ?seatIncumbency :incumbencyEndDate ?seatIncumbencyEndDate . }
            ?houseSeat :houseSeatHasHouse ?house .
            ?house :houseName ?houseName .
            OPTIONAL {
                ?houseSeat :houseSeatHasConstituencyGroup ?constituencyGroup .
                ?constituencyGroup :constituencyGroupName ?constituencyName .
            }
        }
        ?person :partyMemberHasPartyMembership ?partyMembership .
        ?partyMembership :partyMembershipHasParty ?party .
        OPTIONAL { ?partyMembership :partyMembershipEndDate ?partyMembershipEndDate . }
        ?party :partyName ?partyName .
        FILTER STRSTARTS(LCASE(?listAs), LCASE(\"#{letter}\"))
        }
    }
    UNION {
        SELECT DISTINCT ?firstLetter WHERE {

            ?incumbency a :Incumbency ;
                        :incumbencyHasMember ?person.
          ?person <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs .

          BIND(ucase(SUBSTR(?listAs, 1, 1)) as ?firstLetter)
        }
      }
}"
  end

  def self.a_z_letters
    'PREFIX parl: <http://id.ukpds.org/schema/>
     CONSTRUCT {
         _:x parl:value ?firstLetter .
      }
      WHERE {
        SELECT DISTINCT ?firstLetter WHERE {
	        ?incumbency a parl:Incumbency ;
                        parl:incumbencyHasMember ?person .
          ?person <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs .

          BIND(ucase(SUBSTR(?listAs, 1, 1)) as ?firstLetter)
        }
      }'
  end

  def self.all_current
    'PREFIX :<http://id.ukpds.org/schema/>
CONSTRUCT {
    ?houseSeat
        a :HouseSeat ;
        :houseSeatHasHouse ?house ;
        :houseSeatHasConstituencyGroup ?constituencyGroup .
    ?person
        a :Person ;
        :personGivenName ?givenName ;
        :personFamilyName ?familyName ;
        <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs ;
        <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs ;
        :memberHasIncumbency ?incumbency ;
        :partyMemberHasPartyMembership ?partyMembership .
    ?seatIncumbency
        a :SeatIncumbency ;
        :seatIncumbencyHasHouseSeat ?houseSeat ;
        :incumbencyEndDate ?seatIncumbencyEndDate .
    ?houseIncumbency
        a :HouseIncumbency ;
        :houseIncumbencyHasHouse ?house ;
        :incumbencyEndDate ?houseIncumbencyEndDate .
    ?house
        a :House ;
        :houseName ?houseName .
    ?constituencyGroup
        a :ConstituencyGroup ;
        :constituencyGroupName ?constituencyName .
    ?partyMembership
        a :PartyMembership ;
        :partyMembershipHasParty ?party ;
        :partyMembershipEndDate ?partyMembershipEndDate .
    ?party
        a :Party ;
        :partyName ?partyName .
    _:x :value ?firstLetter .
}
WHERE {
    { SELECT * WHERE {
        ?person
            a :Person ;
            :memberHasIncumbency ?incumbency .
        OPTIONAL { ?person :personGivenName ?givenName . }
        OPTIONAL { ?person :personFamilyName ?familyName . }
        OPTIONAL { ?person <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs } .
        ?person <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs .
        {
            ?incumbency a :HouseIncumbency .
            BIND(?incumbency AS ?houseIncumbency)
            ?houseIncumbency :houseIncumbencyHasHouse ?house .
            ?house :houseName ?houseName .
            OPTIONAL { ?houseIncumbency :incumbencyEndDate ?houseIncumbencyEndDate . }
        }
        UNION {
            ?incumbency a :SeatIncumbency .
            BIND(?incumbency AS ?seatIncumbency)
            ?seatIncumbency
                :seatIncumbencyHasHouseSeat ?houseSeat .
            OPTIONAL { ?seatIncumbency :incumbencyEndDate ?seatIncumbencyEndDate . }
            ?houseSeat :houseSeatHasHouse ?house .
            ?house :houseName ?houseName .
            OPTIONAL {
                ?houseSeat :houseSeatHasConstituencyGroup ?constituencyGroup .
                ?constituencyGroup :constituencyGroupName ?constituencyName .
            }
        }
        ?person :partyMemberHasPartyMembership ?partyMembership .
        ?partyMembership :partyMembershipHasParty ?party .
        ?party :partyName ?partyName .
        OPTIONAL { ?partyMembership :partyMembershipEndDate ?partyMembershipEndDate . }
        FILTER NOT EXISTS {?incumbency a :PastIncumbency}
      }
    }
          UNION {
        SELECT DISTINCT ?firstLetter WHERE {
	        ?incumbency a :Incumbency ;
          	FILTER NOT EXISTS { ?incumbency a :PastIncumbency .	}
          	?incumbency :incumbencyHasMember ?person .
          	?person <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs .
          	BIND(ucase(SUBSTR(?listAs, 1, 1)) as ?firstLetter)
        }
      }
}'
  end

  def self.all_current_by_letter(letter)
    "PREFIX : <http://id.ukpds.org/schema/>
CONSTRUCT {
    ?houseSeat
        a :HouseSeat ;
        :houseSeatHasHouse ?house ;
        :houseSeatHasConstituencyGroup ?constituencyGroup .
    ?person
        a :Person ;
        :personGivenName ?givenName ;
        :personFamilyName ?familyName ;
        <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs ;
        <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs ;
        :memberHasIncumbency ?incumbency ;
        :partyMemberHasPartyMembership ?partyMembership .
    ?seatIncumbency
        a :SeatIncumbency ;
        :seatIncumbencyHasHouseSeat ?houseSeat ;
        :incumbencyEndDate ?seatIncumbencyEndDate .
    ?houseIncumbency
        a :HouseIncumbency ;
        :houseIncumbencyHasHouse ?house ;
        :incumbencyEndDate ?houseIncumbencyEndDate .
    ?house
        a :House ;
        :houseName ?houseName .
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
    _:x :value ?firstLetter .
}
WHERE {
    { SELECT * WHERE {
        ?person
            a :Person ;
            :memberHasIncumbency ?incumbency .
        OPTIONAL { ?person :personGivenName ?givenName . }
        OPTIONAL { ?person :personFamilyName ?familyName . }
        OPTIONAL { ?person <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs } .
        ?person <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs .
        {
            ?incumbency a :HouseIncumbency .
            BIND(?incumbency AS ?houseIncumbency)
            ?houseIncumbency :houseIncumbencyHasHouse ?house .
            ?house :houseName ?houseName .
            OPTIONAL { ?houseIncumbency :incumbencyEndDate ?houseIncumbencyEndDate . }
        }
        UNION {
            ?incumbency a :SeatIncumbency .
            BIND(?incumbency AS ?seatIncumbency)
            ?seatIncumbency :seatIncumbencyHasHouseSeat ?houseSeat .
            OPTIONAL { ?seatIncumbency :incumbencyEndDate ?seatIncumbencyEndDate . }
            ?houseSeat :houseSeatHasHouse ?house .
            ?house :houseName ?houseName .
            OPTIONAL {
                ?houseSeat :houseSeatHasConstituencyGroup ?constituencyGroup .
                ?constituencyGroup :constituencyGroupName ?constituencyName .
            }
        }
        ?person :partyMemberHasPartyMembership ?partyMembership .
        ?partyMembership :partyMembershipHasParty ?party .
        ?party :partyName ?partyName .
        OPTIONAL { ?partyMembership :partyMembershipEndDate ?partyMembershipEndDate . }
        FILTER NOT EXISTS {?incumbency a :PastIncumbency}
        FILTER STRSTARTS(LCASE(?listAs), LCASE(\"#{letter}\")) .
        }
    }
    UNION {
        SELECT DISTINCT ?firstLetter WHERE {
	        ?incumbency a :Incumbency ;
          FILTER NOT EXISTS { ?incumbency a :PastIncumbency .	}
          ?incumbency :incumbencyHasMember ?person .
          ?person <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs .
          BIND(ucase(SUBSTR(?listAs, 1, 1)) as ?firstLetter)
        }
      }
}"
  end

  # This will go.
  def self.a_z_letters_current
    'PREFIX parl: <http://id.ukpds.org/schema/>
     CONSTRUCT {
         _:x parl:value ?firstLetter .
      }
      WHERE {
        SELECT DISTINCT ?firstLetter WHERE {
	        ?incumbency a parl:Incumbency ;
          FILTER NOT EXISTS { ?incumbency a parl:PastIncumbency .	}
          ?incumbency parl:incumbencyHasMember ?person .
          ?person <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs .
          BIND(ucase(SUBSTR(?listAs, 1, 1)) as ?firstLetter)
        }
      }'
  end
end