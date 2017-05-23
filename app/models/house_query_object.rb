class HouseQueryObject
  extend QueryObject

  def self.all
    'PREFIX parl: <http://id.ukpds.org/schema/>
     CONSTRUCT {
          ?house
            a parl:House ;
        	  parl:houseName ?houseName .
      }
      WHERE {
          ?house
             a parl:House ;
    			   parl:houseName ?houseName .
      }'
  end

  def self.lookup(source, id)
    "PREFIX parl: <http://id.ukpds.org/schema/>
     CONSTRUCT {
        ?house
           a parl:House .
      }
      WHERE {
        BIND(\"#{id}\" AS ?id)
        BIND(parl:#{source} AS ?source)

	      ?house a parl:House .
        ?house ?source ?id .
      }"
  end

  def self.find(id)
    "PREFIX parl: <http://id.ukpds.org/schema/>
     CONSTRUCT {
          ?house
            a parl:House ;
            parl:houseName ?houseName .
      }
      WHERE {
          BIND(<#{DATA_URI_PREFIX}/#{id}> AS ?house)

          ?house
            a parl:House ;
            parl:houseName ?houseName .
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
        :memberHasIncumbency ?incumbency ;
        :partyMemberHasPartyMembership ?partyMembership .
    ?house
        a :House ;
        :houseName ?houseName .
   ?seatIncumbency
        a :SeatIncumbency ;
        :seatIncumbencyHasHouseSeat ?houseSeat ;
        :incumbencyEndDate ?seatIncumbencyEndDate .
    ?houseIncumbency
        a :HouseIncumbency ;
        :houseIncumbencyHasHouse ?house ;
        :incumbencyEndDate ?houseIncumbencyEndDate .
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
    _:x :value ?firstLetter .
}
WHERE {
    { SELECT * WHERE {
        BIND(<#{DATA_URI_PREFIX}/#{id}> AS ?house)
        ?house
            a :House ;
            :houseName ?houseName .
        ?person a :Member .
        ?incumbency
            :incumbencyHasMember ?person .
        OPTIONAL { ?person :personGivenName ?givenName . }
        OPTIONAL { ?person :personFamilyName ?familyName . }
        OPTIONAL { ?person <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs } .
        ?person <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs .
        {
            ?incumbency :houseIncumbencyHasHouse ?house .
            OPTIONAL { ?incumbency :incumbencyEndDate ?houseIncumbencyEndDate . }
            BIND(?incumbency AS ?houseIncumbency)
        }
        UNION {
            ?incumbency :seatIncumbencyHasHouseSeat ?houseSeat .
            OPTIONAL { ?incumbency :incumbencyEndDate ?seatIncumbencyEndDate . }
            ?houseSeat :houseSeatHasHouse ?house .
            BIND(?incumbency AS ?seatIncumbency)
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
          BIND(<#{DATA_URI_PREFIX}/#{id}> AS ?house)

          ?house a :House .
    	    ?person a :Member ;
                  <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs .
    	    ?incumbency :incumbencyHasMember ?person .

    	    {
    	        ?incumbency :houseIncumbencyHasHouse ?house .
    	    }

    	    UNION {
            	?incumbency :seatIncumbencyHasHouseSeat ?seat .
            	?seat :houseSeatHasHouse ?house .
    	    }

          BIND(ucase(SUBSTR(?listAs, 1, 1)) as ?firstLetter)
        }
      }
}"
  end

  def self.members_by_letter(id, letter)
    "PREFIX : <http://id.ukpds.org/schema/>
CONSTRUCT {
    ?person
        a :Person ;
        :personGivenName ?givenName ;
        :personFamilyName ?familyName ;
        <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs ;
        <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs ;
        :memberHasIncumbency ?incumbency ;
        :partyMemberHasPartyMembership ?partyMembership .
    ?house
        a :House ;
        :houseName ?houseName .
   ?seatIncumbency
        a :SeatIncumbency ;
        :seatIncumbencyHasHouseSeat ?houseSeat ;
        :incumbencyEndDate ?seatIncumbencyEndDate .
    ?houseIncumbency
        a :HouseIncumbency ;
        :houseIncumbencyHasHouse ?house ;
        :incumbencyEndDate ?houseIncumbencyEndDate .
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
    _:x :value ?firstLetter .
}
WHERE {
    { SELECT * WHERE {
        BIND(<#{DATA_URI_PREFIX}/#{id}> AS ?house)
        ?house
            a :House ;
            :houseName ?houseName .
        ?person a :Member .
        ?incumbency
            :incumbencyHasMember ?person .
        OPTIONAL { ?person :personGivenName ?givenName . }
        OPTIONAL { ?person :personFamilyName ?familyName . }
        OPTIONAL { ?person <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs } .
        ?person <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs .
        {
            ?incumbency :houseIncumbencyHasHouse ?house .
            OPTIONAL { ?incumbency :incumbencyEndDate ?houseIncumbencyEndDate . }
            BIND(?incumbency AS ?houseIncumbency)
        }
        UNION {
            ?incumbency :seatIncumbencyHasHouseSeat ?houseSeat .
            OPTIONAL { ?incumbency :incumbencyEndDate ?seatIncumbencyEndDate . }
            ?houseSeat :houseSeatHasHouse ?house .
            BIND(?incumbency AS ?seatIncumbency)
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
        FILTER STRSTARTS(LCASE(?listAs), LCASE(\"#{letter}\"))
       }
    }
    UNION {
        SELECT DISTINCT ?firstLetter WHERE {
          BIND(<#{DATA_URI_PREFIX}/#{id}> AS ?house)

          ?house a :House .
    	    ?person a :Member ;
                  <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs .
    	    ?incumbency :incumbencyHasMember ?person .

    	    {
    	        ?incumbency :houseIncumbencyHasHouse ?house .
    	    }

    	    UNION {
            	?incumbency :seatIncumbencyHasHouseSeat ?seat .
            	?seat :houseSeatHasHouse ?house .
    	    }

          BIND(ucase(SUBSTR(?listAs, 1, 1)) as ?firstLetter)
        }
      }
}"
  end

  def self.a_z_letters_members(id)
    "PREFIX parl: <http://id.ukpds.org/schema/>
     CONSTRUCT {
         _:x parl:value ?firstLetter .
      }
      WHERE {
        SELECT DISTINCT ?firstLetter WHERE {
          BIND(<#{DATA_URI_PREFIX}/#{id}> AS ?house)

          ?house a parl:House ;
	               parl:houseName ?houseName .
    	    ?person a parl:Member ;
                  <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs .
    	    ?incumbency parl:incumbencyHasMember ?person .

    	    {
    	        ?incumbency parl:houseIncumbencyHasHouse ?house .
    	    }

    	    UNION {
            	?incumbency parl:seatIncumbencyHasHouseSeat ?seat .
            	?seat parl:houseSeatHasHouse ?house .
    	    }

          BIND(ucase(SUBSTR(?listAs, 1, 1)) as ?firstLetter)
        }
      }"
  end

  def self.current_members(id)
    "PREFIX : <http://id.ukpds.org/schema/>
PREFIX parl: <http://id.ukpds.org/schema/>
CONSTRUCT {
    ?person
        a :Person ;
        :personGivenName ?givenName ;
        :personFamilyName ?familyName ;
        <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs ;
        <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs ;
        :memberHasIncumbency ?incumbency ;
        :partyMemberHasPartyMembership ?partyMembership .
    ?house
        a :House ;
        :houseName ?houseName .
   ?seatIncumbency
        a :SeatIncumbency ;
        :seatIncumbencyHasHouseSeat ?houseSeat .
    ?houseIncumbency
        a :HouseIncumbency ;
        :houseIncumbencyHasHouse ?house .
    ?houseSeat
        a :HouseSeat ;
        :houseSeatHasHouse ?house ;
        :houseSeatHasConstituencyGroup ?constituencyGroup .
   ?constituencyGroup
        a :ConstituencyGroup;
        :constituencyGroupName ?constituencyName .
    ?partyMembership
        a :PartyMembership ;
        :partyMembershipHasParty ?party .
    ?party
        a :Party ;
        :partyName ?partyName .
    _:x :value ?firstLetter .
}
WHERE {
    { SELECT * WHERE {
        BIND(<#{DATA_URI_PREFIX}/#{id}> AS ?house)
        ?house
            a :House ;
            :houseName ?houseName .
        OPTIONAL {
            ?person a :Member .
            ?incumbency
                :incumbencyHasMember ?person .
            FILTER NOT EXISTS { ?incumbency a :PastIncumbency . }
            OPTIONAL { ?person :personGivenName ?givenName . }
            OPTIONAL { ?person :personFamilyName ?familyName . }
            OPTIONAL { ?person <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs } .
            ?person <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs .
            {
                ?incumbency :houseIncumbencyHasHouse ?house .
                BIND(?incumbency AS ?houseIncumbency)
            }
            UNION {
                ?incumbency :seatIncumbencyHasHouseSeat ?houseSeat .
                ?houseSeat :houseSeatHasHouse ?house .
                BIND(?incumbency AS ?seatIncumbency)
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
    }
    UNION {
        SELECT DISTINCT ?firstLetter WHERE {
          BIND(<#{DATA_URI_PREFIX}/#{id}> AS ?house)

          ?house a :House .
    	    ?person a :Member ;
                  <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs .
    	    ?incumbency :incumbencyHasMember ?person .
            FILTER NOT EXISTS { ?incumbency a parl:PastIncumbency . }

    	    {
    	        ?incumbency :houseIncumbencyHasHouse ?house .
    	    }

    	    UNION {
            	?incumbency :seatIncumbencyHasHouseSeat ?seat .
            	?seat :houseSeatHasHouse ?house .
    	    }

          BIND(ucase(SUBSTR(?listAs, 1, 1)) as ?firstLetter)
        }
      }
}"
  end

  def self.current_members_by_letter(id, letter)
    "PREFIX : <http://id.ukpds.org/schema/>
CONSTRUCT {
    ?person
        a :Person ;
        :personGivenName ?givenName ;
        :personFamilyName ?familyName ;
        <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs ;
        <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs ;
        :memberHasIncumbency ?incumbency ;
        :partyMemberHasPartyMembership ?partyMembership .
    ?house
        a :House ;
        :houseName ?houseName .
   ?seatIncumbency
        a :SeatIncumbency ;
        :seatIncumbencyHasHouseSeat ?houseSeat .
    ?houseIncumbency
        a :HouseIncumbency ;
        :houseIncumbencyHasHouse ?house .
    ?houseSeat
        a :HouseSeat ;
        :houseSeatHasHouse ?house ;
        :houseSeatHasConstituencyGroup ?constituencyGroup .
   ?constituencyGroup
        a :ConstituencyGroup;
        :constituencyGroupName ?constituencyName .
    ?partyMembership
        a :PartyMembership ;
        :partyMembershipHasParty ?party .
    ?party
        a :Party ;
        :partyName ?partyName .
    _:x :value ?firstLetter .
}
WHERE {
    { SELECT * WHERE {
        BIND(<#{DATA_URI_PREFIX}/#{id}> AS ?house)
        ?house
            a :House ;
            :houseName ?houseName .
        OPTIONAL {
            ?person a :Member .
            ?incumbency
                :incumbencyHasMember ?person .
            FILTER NOT EXISTS { ?incumbency a :PastIncumbency . }
            OPTIONAL { ?person :personGivenName ?givenName . }
            OPTIONAL { ?person :personFamilyName ?familyName . }
            OPTIONAL { ?person <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs } .
            ?person <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs .
            {
                ?incumbency :houseIncumbencyHasHouse ?house .
                BIND(?incumbency AS ?houseIncumbency)
            }
            UNION {
                ?incumbency :seatIncumbencyHasHouseSeat ?houseSeat .
                ?houseSeat :houseSeatHasHouse ?house .
                BIND(?incumbency AS ?seatIncumbency)
                OPTIONAL { ?houseSeat :houseSeatHasConstituencyGroup ?constituencyGroup .
                    ?constituencyGroup :constituencyGroupName ?constituencyName .
                    FILTER NOT EXISTS { ?constituencyGroup a :PastConstituencyGroup . }
                }
            }
            OPTIONAL {
                ?person :partyMemberHasPartyMembership ?partyMembership .
                FILTER NOT EXISTS { ?partyMembership a :PastPartyMembership . }
                ?partyMembership :partyMembershipHasParty ?party .
                ?party :partyName ?partyName .
            }
            FILTER STRSTARTS(LCASE(?listAs), LCASE(\"#{letter}\"))
        }
       }
    }
    UNION {
        SELECT DISTINCT ?firstLetter WHERE {
          BIND(<#{DATA_URI_PREFIX}/#{id}> AS ?house)

          ?house a :House .
    	    ?person a :Member ;
                  <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs .
    	    ?incumbency :incumbencyHasMember ?person .
            FILTER NOT EXISTS { ?incumbency a :PastIncumbency . }
    	    {
    	        ?incumbency :houseIncumbencyHasHouse ?house .
    	    }
    	    UNION {
            	?incumbency :seatIncumbencyHasHouseSeat ?seat .
            	?seat :houseSeatHasHouse ?house .
    	    }

          BIND(ucase(SUBSTR(?listAs, 1, 1)) as ?firstLetter)
        }
      }
}"
  end

  def self.a_z_letters_members_current(id)
    "PREFIX parl: <http://id.ukpds.org/schema/>
     CONSTRUCT {
         _:x parl:value ?firstLetter .
      }
      WHERE {
        SELECT DISTINCT ?firstLetter WHERE {
          BIND(<#{DATA_URI_PREFIX}/#{id}> AS ?house)

          ?house a parl:House ;
	               parl:houseName ?houseName .
    	    ?person a parl:Member;
       			      <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs .
    	    ?incumbency parl:incumbencyHasMember ?person .
    	    FILTER NOT EXISTS { ?incumbency a parl:PastIncumbency . }

    	    {
    	        ?incumbency parl:houseIncumbencyHasHouse ?house .
    	    }

    	    UNION {
            	?incumbency parl:seatIncumbencyHasHouseSeat ?seat .
            	?seat parl:houseSeatHasHouse ?house .
    	    }

          BIND(ucase(SUBSTR(?listAs, 1, 1)) as ?firstLetter)
        }
      }"
  end

  def self.parties(id)
    "PREFIX parl: <http://id.ukpds.org/schema/>
     CONSTRUCT {
       ?house
        	a parl:House ;
        	parl:houseName ?houseName .
        ?party
          a parl:Party ;
          parl:partyName ?partyName .
      }
      WHERE {
        BIND(<#{DATA_URI_PREFIX}/#{id}> as ?house)

        ?house a parl:House ;
               parl:houseName ?houseName .
        ?person a parl:Member .
        ?incumbency parl:incumbencyHasMember ?person ;
                    parl:incumbencyStartDate ?incStartDate .
        OPTIONAL { ?incumbency parl:incumbencyEndDate ?incumbencyEndDate . }

        {
            ?incumbency parl:houseIncumbencyHasHouse ?house .
        }
        UNION
        {
            ?incumbency parl:seatIncumbencyHasHouseSeat ?houseSeat .
            ?houseSeat parl:houseSeatHasHouse ?house .
        }

        ?partyMembership parl:partyMembershipHasPartyMember ?person ;
            			parl:partyMembershipHasParty ?party ;
            			parl:partyMembershipStartDate ?pmStartDate .
        OPTIONAL { ?partyMembership parl:partyMembershipEndDate ?partyMembershipEndDate . }
        ?party parl:partyName ?partyName.

        BIND(COALESCE(?partyMembershipEndDate,now()) AS ?pmEndDate)
        BIND(COALESCE(?incumbencyEndDate,now()) AS ?incEndDate)

        FILTER (
            (?pmStartDate<=?incStartDate && ?pmEndDate>?incStartDate) ||
            (?pmStartDate>=?incStartDate && ?pmStartDate<?incEndDate)
        )
      }"
  end

  def self.current_parties(id)
    "PREFIX : <http://id.ukpds.org/schema/>
CONSTRUCT {
    ?house
        a :House ;
        :houseName ?houseName .
    ?party
        a :Party ;
        :partyName ?partyName ;
        :count ?memberCount .
}
WHERE {
    BIND(<#{DATA_URI_PREFIX}/#{id}> AS ?house)
    ?house :houseName ?houseName .
    OPTIONAL
    {
        SELECT ?party ?partyName (COUNT(?membership) AS ?memberCount)
        WHERE {
            BIND(<#{DATA_URI_PREFIX}/#{id}> AS ?house)
            {
                ?house :houseHasHouseSeat/:houseSeatHasSeatIncumbency ?incumbency .
            }
            UNION
            {
                ?house :houseHasHouseIncumbency ?incumbency .
            }
            FILTER NOT EXISTS {
                ?incumbency a :PastIncumbency .
            }
            ?incumbency :incumbencyHasMember/:partyMemberHasPartyMembership ?membership .
            ?membership :partyMembershipHasParty ?party .
            ?party :partyName ?partyName .
            FILTER NOT EXISTS {
                ?membership a :PastPartyMembership .
            }
        }
        GROUP BY ?party ?partyName
    }
}"
  end

  def self.party(house_id, party_id)
    "PREFIX parl: <http://id.ukpds.org/schema/>
     CONSTRUCT {
          ?house
            a parl:House ;
            parl:houseName ?houseName .
          ?party
            a parl:Party ;
            parl:partyName ?partyName .
      }
      WHERE {
          BIND(<#{DATA_URI_PREFIX}/#{house_id}> AS ?house)

          ?house a parl:House ;
                 parl:houseName ?houseName .

          OPTIONAL {
            BIND(<#{DATA_URI_PREFIX}/#{party_id}> AS ?party)

            ?party a parl:Party .
    		    ?person a parl:Member .
    		    ?person parl:partyMemberHasPartyMembership ?partyMembership .
    		    ?partyMembership parl:partyMembershipHasParty ?party .
    		    ?party parl:partyName ?partyName .
    		    ?incumbency parl:incumbencyHasMember ?person .

    	      {
    	          ?incumbency parl:houseIncumbencyHasHouse ?house .
    	      }

    	      UNION {
              	?incumbency parl:seatIncumbencyHasHouseSeat ?seat .
              	?seat parl:houseSeatHasHouse ?house .
    	      }
          }
      }"
  end

  def self.count_party_members_current(house_id, party_id)
    "PREFIX parl: <http://id.ukpds.org/schema/>
     CONSTRUCT {
         ?party parl:count ?currentMemberCount .
      }
      WHERE {
    	SELECT ?party (COUNT(?currentMember) AS ?currentMemberCount) WHERE {
          BIND(<#{DATA_URI_PREFIX}/#{house_id}> AS ?house)
          BIND(<#{DATA_URI_PREFIX}/#{party_id}> AS ?party)

          ?house a parl:House .
          ?party a parl:Party .

          OPTIONAL {
    	      ?party parl:partyHasPartyMembership ?partyMembership .
    	      FILTER NOT EXISTS { ?partyMembership a parl:PastPartyMembership . }
    	      ?partyMembership parl:partyMembershipHasPartyMember ?currentMember .
    	      ?currentMember parl:memberHasIncumbency ?incumbency .
    	      FILTER NOT EXISTS { ?incumbency a parl:PastIncumbency . }

            {
    	          ?incumbency parl:houseIncumbencyHasHouse ?house .
    	      }

    	      UNION {
              	?incumbency parl:seatIncumbencyHasHouseSeat ?seat .
              	?seat parl:houseSeatHasHouse ?house .
    	      }
          }
        }
        GROUP BY ?party
      }"
  end

  def self.party_members(house_id, party_id)
    "PREFIX : <http://id.ukpds.org/schema/>
PREFIX parl: <http://id.ukpds.org/schema/>
CONSTRUCT {
    ?person
        a :Person ;
        :personGivenName ?givenName ;
        :personFamilyName ?familyName ;
        <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs ;
        <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs ;
        :partyMemberHasPartyMembership ?partyMembership ;
        :memberHasIncumbency ?incumbency .
    ?house
        a :House ;
        :houseName ?houseName .
   ?seatIncumbency
        a :SeatIncumbency ;
        :seatIncumbencyHasHouseSeat ?houseSeat ;
        :incumbencyEndDate ?seatIncumbencyEndDate .
    ?houseIncumbency
        a :HouseIncumbency ;
        :houseIncumbencyHasHouse ?house ;
        :incumbencyEndDate ?houseIncumbencyEndDate .
   ?houseSeat
        a :HouseSeat ;
        :houseSeatHasHouse ?house ;
        :houseSeatHasConstituencyGroup ?constituencyGroup .
   ?constituencyGroup
        a :ConstituencyGroup ;
        :constituencyGroupName ?constituencyName .
    ?party
        a :Party ;
        :partyName ?partyName .
    ?partyMembership
        a :PartyMembership ;
        :partyMembershipHasParty ?party ;
        :partyMembershipEndDate ?partyMembershipEndDate .
    _:x :value ?firstLetter .
}
WHERE {
    { SELECT * WHERE {
        BIND(<#{DATA_URI_PREFIX}/#{house_id}> AS ?house)
        ?house a :House ;
               :houseName ?houseName .
         OPTIONAL {
            BIND(<#{DATA_URI_PREFIX}/#{party_id}> AS ?party)
            ?party a :Party ;
                   :partyName ?partyName .
            ?person
                a :Member ;
                :partyMemberHasPartyMembership ?partyMembership .
            ?partyMembership :partyMembershipHasParty ?party .
            OPTIONAL { ?partyMembership :partyMembershipEndDate ?partyMembershipEndDate . }
            ?incumbency
                :incumbencyHasMember ?person .
            OPTIONAL { ?person :personGivenName ?givenName . }
            OPTIONAL { ?person :personFamilyName ?familyName . }
            OPTIONAL { ?person <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs } .
            ?person <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs .
            {
                ?incumbency :houseIncumbencyHasHouse ?house .
                OPTIONAL { ?incumbency :incumbencyEndDate ?houseIncumbencyEndDate . }
                BIND(?incumbency AS ?houseIncumbency)
            }
            UNION {
                ?incumbency :seatIncumbencyHasHouseSeat ?houseSeat .
                OPTIONAL { ?incumbency :incumbencyEndDate ?seatIncumbencyEndDate . }
                ?houseSeat :houseSeatHasHouse ?house .
                BIND(?incumbency AS ?seatIncumbency)
                OPTIONAL { ?houseSeat :houseSeatHasConstituencyGroup ?constituencyGroup .
                    ?constituencyGroup :constituencyGroupName ?constituencyName .
                    FILTER NOT EXISTS { ?constituencyGroup a :PastConstituencyGroup . }
                }
            }
		}
       }
    }
    UNION {
        SELECT DISTINCT ?firstLetter WHERE {
          BIND(<#{DATA_URI_PREFIX}/#{house_id}> AS ?house)
          BIND(<#{DATA_URI_PREFIX}/#{party_id}> AS ?party)

          ?house a :House .
          ?party a :Party .
    	  ?person a :Member ;
          		<http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs ;
    	    	  :partyMemberHasPartyMembership ?partyMembership .
    	    ?partyMembership :partyMembershipHasParty ?party .
    	    ?incumbency :incumbencyHasMember ?person .

    	    {
    	        ?incumbency :houseIncumbencyHasHouse ?house .
    	    }

    	    UNION {
            	?incumbency :seatIncumbencyHasHouseSeat ?seat .
            	?seat :houseSeatHasHouse ?house .
    	    }

          BIND(ucase(SUBSTR(?listAs, 1, 1)) as ?firstLetter)
        }
      }
}"
  end

  def self.party_members_letters(house_id, party_id, letter)
    "PREFIX : <http://id.ukpds.org/schema/>
CONSTRUCT {
    ?person
        a :Person ;
        :personGivenName ?givenName ;
        :personFamilyName ?familyName ;
        <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs ;
        <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs ;
        :partyMemberHasPartyMembership ?partyMembership ;
        :memberHasIncumbency ?incumbency .
    ?house
        a :House ;
        :houseName ?houseName .
   ?seatIncumbency
        a :SeatIncumbency ;
        :seatIncumbencyHasHouseSeat ?houseSeat ;
        :incumbencyEndDate ?seatIncumbencyEndDate .
    ?houseIncumbency
        a :HouseIncumbency ;
        :houseIncumbencyHasHouse ?house ;
        :incumbencyEndDate ?houseIncumbencyEndDate .
   ?houseSeat
        a :HouseSeat ;
        :houseSeatHasHouse ?house ;
        :houseSeatHasConstituencyGroup ?constituencyGroup .
   ?constituencyGroup
        a :ConstituencyGroup ;
        :constituencyGroupName ?constituencyName .
    ?party
        a :Party ;
        :partyName ?partyName .
    ?partyMembership
        a :PartyMembership ;
        :partyMembershipHasParty ?party ;
        :partyMembershipEndDate ?partyMembershipEndDate .
    _:x :value ?firstLetter .
}
WHERE {
    { SELECT * WHERE {
        BIND(<#{DATA_URI_PREFIX}/#{house_id}> AS ?house)
        BIND(<#{DATA_URI_PREFIX}/#{party_id}> AS ?party)

        ?house a :House ;
               :houseName ?houseName .
        ?party a :Party ;
               :partyName ?partyName .
         OPTIONAL {
            ?person
                a :Member ;
                :partyMemberHasPartyMembership ?partyMembership .
            ?partyMembership :partyMembershipHasParty ?party .
            OPTIONAL { ?partyMembership :partyMembershipEndDate ?partyMembershipEndDate . }
            ?incumbency
                :incumbencyHasMember ?person .
            OPTIONAL { ?person :personGivenName ?givenName . }
            OPTIONAL { ?person :personFamilyName ?familyName . }
            OPTIONAL { ?person <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs } .
            ?person <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs .
            {
                ?incumbency :houseIncumbencyHasHouse ?house .
                OPTIONAL { ?incumbency :incumbencyEndDate ?houseIncumbencyEndDate . }
                BIND(?incumbency AS ?houseIncumbency)
            }
            UNION {
                ?incumbency :seatIncumbencyHasHouseSeat ?houseSeat .
                OPTIONAL { ?incumbency :incumbencyEndDate ?seatIncumbencyEndDate . }
                ?houseSeat :houseSeatHasHouse ?house .
                BIND(?incumbency AS ?seatIncumbency)
                OPTIONAL { ?houseSeat :houseSeatHasConstituencyGroup ?constituencyGroup .
                    ?constituencyGroup :constituencyGroupName ?constituencyName .
                    FILTER NOT EXISTS { ?constituencyGroup a :PastConstituencyGroup . }
                }
            }
            FILTER STRSTARTS(LCASE(?listAs), LCASE(\"#{letter}\"))
		}
       }
    }
    UNION {
        SELECT DISTINCT ?firstLetter WHERE {
          BIND(<#{DATA_URI_PREFIX}/#{house_id}> AS ?house)
          BIND(<#{DATA_URI_PREFIX}/#{party_id}> AS ?party)

          ?house a :House .
          ?party a :Party .
    	  ?person a :Member ;
          		<http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs ;
    	    	:partyMemberHasPartyMembership ?partyMembership .
    	    ?partyMembership :partyMembershipHasParty ?party .
    	    ?incumbency :incumbencyHasMember ?person .

    	    {
    	        ?incumbency :houseIncumbencyHasHouse ?house .
    	    }

    	    UNION {
            	?incumbency :seatIncumbencyHasHouseSeat ?seat .
            	?seat :houseSeatHasHouse ?house .
    	    }

          BIND(ucase(SUBSTR(?listAs, 1, 1)) as ?firstLetter)
        }
      }
}"
  end

  def self.a_z_letters_party_members(house_id, party_id)
    "PREFIX parl: <http://id.ukpds.org/schema/>
     CONSTRUCT {
         _:x parl:value ?firstLetter .
      }
      WHERE {
        SELECT DISTINCT ?firstLetter WHERE {
          BIND(<#{DATA_URI_PREFIX}/#{house_id}> AS ?house)
          BIND(<#{DATA_URI_PREFIX}/#{party_id}> AS ?party)

          ?house a parl:House .
          ?party a parl:Party .
    	    ?person a parl:Member .
          ?person <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs .
    	    ?person parl:partyMemberHasPartyMembership ?partyMembership .
    	    ?partyMembership parl:partyMembershipHasParty ?party .
    	    ?incumbency parl:incumbencyHasMember ?person .

    	    {
    	        ?incumbency parl:houseIncumbencyHasHouse ?house .
    	    }

    	    UNION {
            	?incumbency parl:seatIncumbencyHasHouseSeat ?seat .
            	?seat parl:houseSeatHasHouse ?house .
    	    }

          BIND(ucase(SUBSTR(?listAs, 1, 1)) as ?firstLetter)
        }
      }"
  end

  def self.current_party_members(house_id, party_id)
    "PREFIX : <http://id.ukpds.org/schema/>
CONSTRUCT {
    ?person
        a :Person ;
        :personGivenName ?givenName ;
        :personFamilyName ?familyName ;
        <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs ;
        <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs ;
        :partyMemberHasPartyMembership ?partyMembership ;
        :memberHasIncumbency ?incumbency .
    ?house
        a :House ;
        :houseName ?houseName .
   ?seatIncumbency
        a :SeatIncumbency ;
        :seatIncumbencyHasHouseSeat ?houseSeat .
    ?houseIncumbency
        a :HouseIncumbency ;
        :houseIncumbencyHasHouse ?house .
   ?houseSeat
        a :HouseSeat ;
        :houseSeatHasHouse ?house ;
        :houseSeatHasConstituencyGroup ?constituencyGroup .
   ?constituencyGroup
        a :ConstituencyGroup ;
        :constituencyGroupName ?constituencyName .
    ?party
        a :Party ;
        :partyName ?partyName .
    ?partyMembership
        a :PartyMembership ;
        :partyMembershipHasParty ?party .
    _:x :value ?firstLetter .
}
WHERE {
    { SELECT * WHERE {
        BIND(<#{DATA_URI_PREFIX}/#{house_id}> AS ?house)
        BIND(<#{DATA_URI_PREFIX}/#{party_id}> AS ?party)

        ?house a :House ;
               :houseName ?houseName .
        ?party a :Party ;
               :partyName ?partyName .
         OPTIONAL {
            ?person
                a :Member ;
                :partyMemberHasPartyMembership ?partyMembership .
            FILTER NOT EXISTS { ?partyMembership a :PastPartyMembership . }
            ?partyMembership :partyMembershipHasParty ?party .
            ?incumbency :incumbencyHasMember ?person .
            FILTER NOT EXISTS { ?incumbency a :PastIncumbency . }
            OPTIONAL { ?person :personGivenName ?givenName . }
            OPTIONAL { ?person :personFamilyName ?familyName . }
            OPTIONAL { ?person <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs } .
            ?person <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs .
            {
                ?incumbency :houseIncumbencyHasHouse ?house .
                BIND(?incumbency AS ?houseIncumbency)
            }
            UNION {
                ?incumbency :seatIncumbencyHasHouseSeat ?houseSeat .
                ?houseSeat :houseSeatHasHouse ?house .
                BIND(?incumbency AS ?seatIncumbency)
                OPTIONAL { ?houseSeat :houseSeatHasConstituencyGroup ?constituencyGroup .
                    ?constituencyGroup :constituencyGroupName ?constituencyName .
                    FILTER NOT EXISTS { ?constituencyGroup a :PastConstituencyGroup . }
                }
            }
      		}
       }
    }
    UNION {
        SELECT DISTINCT ?firstLetter WHERE {
          BIND(<#{DATA_URI_PREFIX}/#{house_id}> AS ?house)
          BIND(<#{DATA_URI_PREFIX}/#{party_id}> AS ?party)

          ?house a :House .
          ?party a :Party .
    	  ?person a :Member ;
          		<http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs ;
    	    	:partyMemberHasPartyMembership ?partyMembership .
          FILTER NOT EXISTS { ?partyMembership a :PastPartyMembership . }

    	    ?partyMembership :partyMembershipHasParty ?party .
    	    ?incumbency :incumbencyHasMember ?person .
           FILTER NOT EXISTS { ?incumbency a :PastIncumbency . }
    	    {
    	        ?incumbency :houseIncumbencyHasHouse ?house .
    	    }
    	    UNION {
            	?incumbency :seatIncumbencyHasHouseSeat ?seat .
            	?seat :houseSeatHasHouse ?house .
    	    }

          BIND(ucase(SUBSTR(?listAs, 1, 1)) as ?firstLetter)
        }
      }
}"
  end

  def self.current_party_members_letters(house_id, party_id, letter)
    "PREFIX : <http://id.ukpds.org/schema/>
CONSTRUCT {
    ?person
        a :Person ;
        :personGivenName ?givenName ;
        :personFamilyName ?familyName ;
        <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs ;
        <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs ;
        :partyMemberHasPartyMembership ?partyMembership ;
        :memberHasIncumbency ?incumbency .
    ?house
        a :House ;
        :houseName ?houseName .
   ?seatIncumbency
        a :SeatIncumbency ;
        :seatIncumbencyHasHouseSeat ?houseSeat .
    ?houseIncumbency
        a :HouseIncumbency ;
        :houseIncumbencyHasHouse ?house .
   ?houseSeat
        a :HouseSeat ;
        :houseSeatHasHouse ?house ;
        :houseSeatHasConstituencyGroup ?constituencyGroup .
   ?constituencyGroup
        a :ConstituencyGroup ;
        :constituencyGroupName ?constituencyName .
    ?party
        a :Party ;
        :partyName ?partyName .
    ?partyMembership
        a :PartyMembership ;
        :partyMembershipHasParty ?party .
    _:x :value ?firstLetter .
}
WHERE {
    { SELECT * WHERE {
        BIND(<#{DATA_URI_PREFIX}/#{house_id}> AS ?house)
        BIND(<#{DATA_URI_PREFIX}/#{party_id}> AS ?party)

        ?house a :House ;
               :houseName ?houseName .
        ?party a :Party ;
               :partyName ?partyName .
         OPTIONAL {
            ?person
                a :Member ;
                :partyMemberHasPartyMembership ?partyMembership .
            FILTER NOT EXISTS { ?partyMembership a :PastPartyMembership . }
            ?partyMembership :partyMembershipHasParty ?party .
            ?incumbency :incumbencyHasMember ?person .
            FILTER NOT EXISTS { ?incumbency a :PastIncumbency . }
            OPTIONAL { ?person :personGivenName ?givenName . }
            OPTIONAL { ?person :personFamilyName ?familyName . }
            OPTIONAL { ?person <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs } .
            ?person <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs .
            {
                ?incumbency :houseIncumbencyHasHouse ?house .
                BIND(?incumbency AS ?houseIncumbency)
            }
            UNION {
                ?incumbency :seatIncumbencyHasHouseSeat ?houseSeat .
                ?houseSeat :houseSeatHasHouse ?house .
                BIND(?incumbency AS ?seatIncumbency)
                OPTIONAL { ?houseSeat :houseSeatHasConstituencyGroup ?constituencyGroup .
                    ?constituencyGroup :constituencyGroupName ?constituencyName .
                    FILTER NOT EXISTS { ?constituencyGroup a :PastConstituencyGroup . }
                }
            }
            FILTER STRSTARTS(LCASE(?listAs), LCASE(\"#{letter}\"))
		}
       }
    }
    UNION {
        SELECT DISTINCT ?firstLetter WHERE {
          BIND(<#{DATA_URI_PREFIX}/#{house_id}> AS ?house)
          BIND(<#{DATA_URI_PREFIX}/#{party_id}> AS ?party)

          ?house a :House .
          ?party a :Party .
    	  ?person a :Member ;
          		<http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs ;
    	    	:partyMemberHasPartyMembership ?partyMembership .
          FILTER NOT EXISTS { ?partyMembership a :PastPartyMembership . }

    	    ?partyMembership :partyMembershipHasParty ?party .
    	    ?incumbency :incumbencyHasMember ?person .
           FILTER NOT EXISTS { ?incumbency a :PastIncumbency . }
    	    {
    	        ?incumbency :houseIncumbencyHasHouse ?house .
    	    }
    	    UNION {
            	?incumbency :seatIncumbencyHasHouseSeat ?seat .
            	?seat :houseSeatHasHouse ?house .
    	    }

          BIND(ucase(SUBSTR(?listAs, 1, 1)) as ?firstLetter)
        }
      }
}"
  end

  def self.a_z_letters_party_members_current(house_id, party_id)
    "PREFIX parl: <http://id.ukpds.org/schema/>
     CONSTRUCT {
         _:x parl:value ?firstLetter .
      }
      WHERE {
        SELECT DISTINCT ?firstLetter WHERE {
          BIND(<#{DATA_URI_PREFIX}/#{house_id}> AS ?house)
          BIND(<#{DATA_URI_PREFIX}/#{party_id}> AS ?party)

          ?house a parl:House .
          ?party a parl:Party .
    	    ?person a parl:Member .
          ?person <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs .
    	    ?person parl:partyMemberHasPartyMembership ?partyMembership .
          FILTER NOT EXISTS { ?partyMembership a parl:PastPartyMembership . }
    	    ?partyMembership parl:partyMembershipHasParty ?party .
    	    ?incumbency parl:incumbencyHasMember ?person .
          FILTER NOT EXISTS { ?incumbency a parl:PastIncumbency . }

    	    {
    	        ?incumbency parl:houseIncumbencyHasHouse ?house .
    	    }

    	    UNION {
            	?incumbency parl:seatIncumbencyHasHouseSeat ?seat .
            	?seat parl:houseSeatHasHouse ?house .
    	    }

          BIND(ucase(SUBSTR(?listAs, 1, 1)) as ?firstLetter)
        }
      }"
  end

  def self.lookup_by_letters(letters)
    "PREFIX parl: <http://id.ukpds.org/schema/>
     CONSTRUCT {
        ?house
        	a parl:House ;
         	parl:houseName ?houseName .
      }
      WHERE {
        ?house a parl:House .
        ?house parl:houseName ?houseName .

    	  FILTER(regex(str(?houseName), \"#{letters}\", 'i')) .
      }"
  end
end
