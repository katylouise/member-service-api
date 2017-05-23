class PartyQueryObject
  extend QueryObject

  def self.all
    'PREFIX parl: <http://id.ukpds.org/schema/>
     CONSTRUCT {
        ?party
           a parl:Party ;
           parl:partyName ?partyName ;
          parl:commonsCount ?commonsCount ;
          parl:lordsCount ?lordsCount .
    	_:x parl:value ?firstLetter .
      }
      WHERE {
    	{ SELECT ?party ?partyName (COUNT(?mp) AS ?commonsCount) (COUNT(?lord) AS ?lordsCount) WHERE 			{
              ?party
            		a parl:Party ;
            		parl:partyHasPartyMembership ?partyMembership ;
            		parl:partyName ?partyName .
                OPTIONAL {
                    ?partyMembership parl:partyMembershipHasPartyMember ?person .
                    FILTER NOT EXISTS { ?partyMembership a parl:PastPartyMembership . }
                    ?person parl:memberHasIncumbency ?incumbency .
                    FILTER NOT EXISTS { ?incumbency a parl:PastIncumbency . }
                    OPTIONAL {
						?incumbency a parl:SeatIncumbency ;
                  					parl:incumbencyHasMember ?mp .
                    }
                    OPTIONAL {
						?incumbency a parl:HouseIncumbency ;
                  					parl:incumbencyHasMember ?lord .
                    }
                }
          	}
        	GROUP BY ?party ?partyName
    	  }
    	  UNION {
        	SELECT DISTINCT ?firstLetter WHERE {
	        	?s a parl:Party ;
            		parl:partyHasPartyMembership ?partyMembership ;
            		parl:partyName ?partyName .

          	BIND(ucase(SUBSTR(?partyName, 1, 1)) as ?firstLetter)
          }
    	  }
     }'
  end

  def self.lookup(source, id)
    "PREFIX parl: <http://id.ukpds.org/schema/>
     CONSTRUCT {
        ?party
           a parl:Party .
      }
      WHERE {
        BIND(\"#{id}\" AS ?id)
        BIND(parl:#{source} AS ?source)

	      ?party a parl:Party .
        ?party ?source ?id .
      }"
  end

  def self.all_current
    'PREFIX parl: <http://id.ukpds.org/schema/>
     CONSTRUCT {
        ?party
              a parl:Party ;
              parl:partyName ?partyName ;
        	  parl:commonsCount ?commonsCount ;
        	  parl:lordsCount ?lordsCount .
      }
	  WHERE {
    	SELECT ?party ?partyName (COUNT(?mp) AS ?commonsCount) (COUNT(?lord) AS ?lordsCount) WHERE {
                ?incumbency a parl:Incumbency .
                FILTER NOT EXISTS { ?incumbency a parl:PastIncumbency . }
                ?incumbency parl:incumbencyHasMember ?person .
                ?person parl:partyMemberHasPartyMembership ?partyMembership .
                FILTER NOT EXISTS { ?partyMembership a parl:PastPartyMembership . }
                ?partyMembership parl:partyMembershipHasParty ?party .
                ?party parl:partyName ?partyName .
            OPTIONAL {
				?incumbency a parl:SeatIncumbency ;
                			parl:incumbencyHasMember ?mp .
            }
            OPTIONAL {
				?incumbency a parl:HouseIncumbency ;
                			parl:incumbencyHasMember ?lord .
            }
      		}
    		GROUP BY ?party ?partyName
		}'
  end

  def self.all_by_letter(letter)
    "PREFIX parl: <http://id.ukpds.org/schema/>
     CONSTRUCT {
        ?party
           a parl:Party ;
           parl:partyName ?partyName ;
           parl:commonsCount ?commonsCount ;
           parl:lordsCount ?lordsCount .
    	_:x parl:value ?firstLetter .
      }
      WHERE {
    { SELECT ?party ?partyName (COUNT(?mp) AS ?commonsCount) (COUNT(?lord) AS ?lordsCount) WHERE {
              ?party
            		a parl:Party ;
            		parl:partyHasPartyMembership ?partyMembership ;
            		parl:partyName ?partyName .
                OPTIONAL {
                    ?partyMembership parl:partyMembershipHasPartyMember ?person .
                    FILTER NOT EXISTS { ?partyMembership a parl:PastPartyMembership . }
                    ?person  parl:memberHasIncumbency ?incumbency .
                    FILTER NOT EXISTS { ?incumbency a parl:PastIncumbency . }
                    OPTIONAL {
						?incumbency a parl:SeatIncumbency ;
                  					parl:incumbencyHasMember ?mp .
                    }
                    OPTIONAL {
						?incumbency a parl:HouseIncumbency ;
                  					parl:incumbencyHasMember ?lord .
                    }
                }

              FILTER regex(str(?partyName), \"^#{letter}\", 'i') .
          	}
        	GROUP BY ?party ?partyName
    	  }
    	  UNION {
        	SELECT DISTINCT ?firstLetter WHERE {
	        	?s a parl:Party ;
            	parl:partyHasPartyMembership ?partyMembership ;
            	parl:partyName ?partyName .

          	BIND(ucase(SUBSTR(?partyName, 1, 1)) as ?firstLetter)
          }
    	  }
     }"
  end

  def self.a_z_letters_all
    'PREFIX parl: <http://id.ukpds.org/schema/>
     CONSTRUCT {
         _:x parl:value ?firstLetter .
      }
      WHERE {
        SELECT DISTINCT ?firstLetter WHERE {
	        ?s a parl:Party ;
            parl:partyHasPartyMembership ?partyMembership ;
            parl:partyName ?partyName .

          BIND(ucase(SUBSTR(?partyName, 1, 1)) as ?firstLetter)
        }
      }'
  end

  def self.find(id)
    "PREFIX parl: <http://id.ukpds.org/schema/>
     CONSTRUCT {
	      ?party a parl:Party ;
               parl:partyName ?name ;
               parl:commonsCount ?commonsCount ;
        	   parl:lordsCount ?lordsCount .
     }
      WHERE {
    	SELECT ?party ?name (COUNT(?mp) AS ?commonsCount) (COUNT(?lord) AS ?lordsCount)
		    WHERE {
          BIND(<#{DATA_URI_PREFIX}/#{id}> AS ?party)

          ?party a parl:Party ;
	               parl:partyName ?name .
          OPTIONAL {
          	?party parl:partyHasPartyMembership ?partyMembership .
    	  	  FILTER NOT EXISTS { ?partyMembership a parl:PastPartyMembership . }
    	  	  ?partyMembership parl:partyMembershipHasPartyMember ?member .
    	  	  ?member parl:memberHasIncumbency ?incumbency .
    	  	  FILTER NOT EXISTS { ?incumbency a parl:PastIncumbency . }
              OPTIONAL {
				?incumbency a parl:SeatIncumbency ;
                			parl:incumbencyHasMember ?mp .
            	}
                OPTIONAL {
                    ?incumbency a parl:HouseIncumbency ;
                                parl:incumbencyHasMember ?lord .
                }
          }
        }
      GROUP BY ?party ?name
    }"
  end

  def self.members(id)
    "PREFIX : <http://id.ukpds.org/schema/>
CONSTRUCT {
    ?party
        a :Party ;
        :partyName ?partyName .
    ?person
        a :Person ;
        :personGivenName ?givenName ;
        :personFamilyName ?familyName ;
        <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs ;
        <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs ;
        :memberHasIncumbency ?incumbency ;
        :partyMemberHasPartyMembership ?partyMembership .
    ?partyMembership
        a :PartyMembership ;
        :partyMembershipEndDate ?partyMembershipEndDate ;
        :partyMembershipHasParty ?party .
    ?houseSeat
        a :HouseSeat ;
        :houseSeatHasConstituencyGroup ?constituencyGroup .
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
    _:x :value ?firstLetter .
}
WHERE {
    { SELECT * WHERE {
        BIND(<#{DATA_URI_PREFIX}/#{id}> AS ?party)
        ?party
            a :Party ;
            :partyName ?partyName .
        OPTIONAL {
            ?party :partyHasPartyMembership ?partyMembership .
            ?partyMembership :partyMembershipHasPartyMember ?person .
            OPTIONAL { ?partyMembership :partyMembershipEndDate ?partyMembershipEndDate . }
            OPTIONAL { ?person :personGivenName ?givenName . }
            OPTIONAL { ?person :personFamilyName ?familyName . }
            OPTIONAL { ?person <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs } .
            ?person <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs ;
                	:memberHasIncumbency ?incumbency .
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
	    }
      }
    }
    UNION {
        SELECT DISTINCT ?firstLetter WHERE {
            BIND(<#{DATA_URI_PREFIX}/#{id}> AS ?party)

            ?party a :Party ;
                   :partyHasPartyMembership ?partyMembership .
            ?partyMembership :partyMembershipHasPartyMember ?person .
            ?person <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs .

            BIND(ucase(SUBSTR(?listAs, 1, 1)) as ?firstLetter)
        }
    }
}"
  end

  def self.members_by_letter(id, letter)
    "PREFIX : <http://id.ukpds.org/schema/>
CONSTRUCT {
    ?party
        a :Party ;
        :partyName ?partyName .
    ?person
        a :Person ;
        :personGivenName ?givenName ;
        :personFamilyName ?familyName ;
        <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs ;
        <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs ;
        :memberHasIncumbency ?incumbency ;
        :partyMemberHasPartyMembership ?partyMembership .
    ?partyMembership
        a :PartyMembership ;
        :partyMembershipEndDate ?partyMembershipEndDate ;
        :partyMembershipHasParty ?party .
    ?houseSeat
        a :HouseSeat ;
        :houseSeatHasConstituencyGroup ?constituencyGroup .
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
    _:x :value ?firstLetter .
}
WHERE {
    { SELECT * WHERE {
        BIND(<#{DATA_URI_PREFIX}/#{id}> AS ?party)
        ?party
            a :Party ;
            :partyName ?partyName .
        OPTIONAL {
            ?party :partyHasPartyMembership ?partyMembership .
            ?partyMembership :partyMembershipHasPartyMember ?person .
            OPTIONAL { ?person :personGivenName ?givenName . }
            OPTIONAL { ?person :personFamilyName ?familyName . }
            OPTIONAL { ?person <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs } .
            OPTIONAL { ?partyMembership :partyMembershipEndDate ?partyMembershipEndDate . }
            ?person <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs ;
                	:memberHasIncumbency ?incumbency .
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
          FILTER STRSTARTS(LCASE(?listAs), LCASE(\"#{letter}\"))
	    }
      }
    }
    UNION {
        SELECT DISTINCT ?firstLetter WHERE {
            BIND(<#{DATA_URI_PREFIX}/#{id}> AS ?party)

            ?party a :Party ;
                   :partyHasPartyMembership ?partyMembership .
            ?partyMembership :partyMembershipHasPartyMember ?person .
            ?person <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs .

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
          BIND(<#{DATA_URI_PREFIX}/#{id}> AS ?party)

          ?party a parl:Party ;
	               parl:partyHasPartyMembership ?partyMembership .
          ?partyMembership parl:partyMembershipHasPartyMember ?person .
          ?person <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs .

          BIND(ucase(SUBSTR(?listAs, 1, 1)) as ?firstLetter)
        }
      }"
  end

  def self.current_members(id)
    "PREFIX : <http://id.ukpds.org/schema/>
CONSTRUCT {
    ?party
        a :Party ;
        :partyName ?partyName .
    ?person
        a :Person ;
        :personGivenName ?givenName ;
        :personFamilyName ?familyName ;
        <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs ;
        <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs ;
        :memberHasIncumbency ?incumbency ;
        :partyMemberHasPartyMembership ?partyMembership .
    ?partyMembership
        a :PartyMembership ;
        :partyMembershipEndDate ?partyMembershipEndDate ;
        :partyMembershipHasParty ?party .
    ?houseSeat
        a :HouseSeat ;
        :houseSeatHasConstituencyGroup ?constituencyGroup .
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
    _:x :value ?firstLetter .
}
WHERE {
    { SELECT * WHERE {
        BIND(<#{DATA_URI_PREFIX}/#{id}> AS ?party)
        ?party
            a :Party ;
            :partyName ?partyName .
        OPTIONAL {
            ?party :partyHasPartyMembership ?partyMembership .
            FILTER NOT EXISTS { ?partyMembership a :PastPartyMembership . }
            ?partyMembership :partyMembershipHasPartyMember ?person .
            OPTIONAL { ?partyMembership :partyMembershipEndDate ?partyMembershipEndDate . }
            OPTIONAL { ?person :personGivenName ?givenName . }
            OPTIONAL { ?person :personFamilyName ?familyName . }
            OPTIONAL { ?person <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs } .
            ?person <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs ;
                	:memberHasIncumbency ?incumbency .
            FILTER NOT EXISTS { ?incumbency a :PastIncumbency . }
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
	    }
      }
    }
    UNION {
        SELECT DISTINCT ?firstLetter WHERE {
            BIND(<#{DATA_URI_PREFIX}/#{id}> AS ?party)

            ?party a :Party ;
                   :partyHasPartyMembership ?partyMembership .
            FILTER NOT EXISTS { ?partyMembership a :PastPartyMembership . }
            ?partyMembership :partyMembershipHasPartyMember ?person .
            ?person :memberHasIncumbency ?incumbency .
            FILTER NOT EXISTS { ?incumbency a :PastIncumbency . }
            ?person <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs .

            BIND(ucase(SUBSTR(?listAs, 1, 1)) as ?firstLetter)
        }
    }
}"
  end

  def self.current_members_by_letter(id, letter)
    "PREFIX : <http://id.ukpds.org/schema/>
CONSTRUCT {
    ?party
        a :Party ;
        :partyName ?partyName .
    ?person
        a :Person ;
        :personGivenName ?givenName ;
        :personFamilyName ?familyName ;
        <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs ;
        <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs ;
        :memberHasIncumbency ?incumbency ;
        :partyMemberHasPartyMembership ?partyMembership .
    ?partyMembership
        a :PartyMembership ;
        :partyMembershipEndDate ?partyMembershipEndDate ;
        :partyMembershipHasParty ?party .
    ?houseSeat
        a :HouseSeat ;
        :houseSeatHasConstituencyGroup ?constituencyGroup .
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
    _:x :value ?firstLetter .
}
WHERE {
    { SELECT * WHERE {
        BIND(<#{DATA_URI_PREFIX}/#{id}> AS ?party)
        ?party
            a :Party ;
            :partyName ?partyName .
        OPTIONAL {
            ?party :partyHasPartyMembership ?partyMembership .
            FILTER NOT EXISTS { ?partyMembership a :PastPartyMembership . }
            ?partyMembership :partyMembershipHasPartyMember ?person .
            OPTIONAL { ?partyMembership :partyMembershipEndDate ?partyMembershipEndDate . }
            OPTIONAL { ?person :personGivenName ?givenName . }
            OPTIONAL { ?person :personFamilyName ?familyName . }
            OPTIONAL { ?person <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs } .
            ?person <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs ;
                	:memberHasIncumbency ?incumbency .
            FILTER NOT EXISTS { ?incumbency a :PastIncumbency . }
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
          FILTER STRSTARTS(LCASE(?listAs), LCASE(\"#{letter}\"))
	    }
      }
    }
    UNION {
        SELECT DISTINCT ?firstLetter WHERE {
            BIND(<#{DATA_URI_PREFIX}/#{id}> AS ?party)

            ?party a :Party ;
                   :partyHasPartyMembership ?partyMembership .
            FILTER NOT EXISTS { ?partyMembership a :PastPartyMembership . }
            ?partyMembership :partyMembershipHasPartyMember ?person .
            ?person :memberHasIncumbency ?incumbency .
            FILTER NOT EXISTS { ?incumbency a :PastIncumbency . }
            ?person <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs .

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
          BIND(<#{DATA_URI_PREFIX}/#{id}> AS ?party)

          ?party a parl:Party ;
	               parl:partyHasPartyMembership ?partyMembership .
          FILTER NOT EXISTS { ?partyMembership a parl:PastPartyMembership . }
          ?partyMembership parl:partyMembershipHasPartyMember ?person .
          ?person parl:memberHasIncumbency ?incumbency .
          FILTER NOT EXISTS { ?incumbency a parl:PastIncumbency . }
          ?person <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs .

          BIND(ucase(SUBSTR(?listAs, 1, 1)) as ?firstLetter)
        }
      }"
  end

  def self.lookup_by_letters(letters)
    "PREFIX parl: <http://id.ukpds.org/schema/>
     CONSTRUCT {
        ?party
        	a parl:Party ;
         	parl:partyName ?partyName .
      }
      WHERE {
        ?party a parl:Party .
        ?party parl:partyName ?partyName .

    	  FILTER(regex(str(?partyName), \"#{letters}\", 'i')) .
      }"
  end
end