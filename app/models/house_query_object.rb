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
    "PREFIX parl: <http://id.ukpds.org/schema/>
     CONSTRUCT {
        ?person
        	  a parl:Person ;
            parl:personGivenName ?givenName ;
            parl:personFamilyName ?familyName ;
            <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs ;
            <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs ;
            parl:memberHasIncumbency ?incumbency .
    	  ?house
        	  a parl:House ;
        	  parl:houseName ?houseName .
    	  ?incumbency
            a parl:Incumbency ;
        	  parl:incumbencyEndDate ?incumbencyEndDate ;
        	  parl:incumbencyStartDate ?incumbencyStartDate .
      }
      WHERE {
        BIND(<#{DATA_URI_PREFIX}/#{id}> AS ?house)

        ?house a parl:House ;
               parl:houseName ?houseName .
    	  ?person a parl:Member .
    	  ?incumbency parl:incumbencyHasMember ?person ;
       				      parl:incumbencyStartDate ?incumbencyStartDate .

        OPTIONAL { ?incumbency parl:incumbencyEndDate ?incumbencyEndDate . }
        OPTIONAL { ?person parl:personGivenName ?givenName . }
        OPTIONAL { ?person parl:personFamilyName ?familyName . }
        OPTIONAL { ?person <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs } .
        ?person <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs .

    	  {
    	      ?incumbency parl:houseIncumbencyHasHouse ?house .
    	  }
    	  UNION {
          	?incumbency parl:seatIncumbencyHasHouseSeat ?seat .
          	?seat parl:houseSeatHasHouse ?house .
    	  }
      }"
  end

  def self.members_by_letter(id, letter)
    "PREFIX parl: <http://id.ukpds.org/schema/>
     CONSTRUCT {
        ?person
        	  a parl:Person ;
            parl:personGivenName ?givenName ;
            parl:personFamilyName ?familyName ;
            <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs ;
            <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs ;
            parl:memberHasIncumbency ?incumbency .
    	  ?house
        	  a parl:House ;
        	  parl:houseName ?houseName .
    	  ?incumbency
            a parl:Incumbency ;
        	  parl:incumbencyEndDate ?incumbencyEndDate ;
        	  parl:incumbencyStartDate ?incumbencyStartDate .
      }
      WHERE {
        BIND(<#{DATA_URI_PREFIX}/#{id}> AS ?house)

        ?house a parl:House ;
               parl:houseName ?houseName .
    	  ?person a parl:Member .
    	  ?incumbency parl:incumbencyHasMember ?person ;
       				      parl:incumbencyStartDate ?incumbencyStartDate .

        OPTIONAL { ?incumbency parl:incumbencyEndDate ?incumbencyEndDate . }
        OPTIONAL { ?person parl:personGivenName ?givenName . }
        OPTIONAL { ?person parl:personFamilyName ?familyName . }
        OPTIONAL { ?person <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs } .
        ?person <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs .

    	  {
    	      ?incumbency parl:houseIncumbencyHasHouse ?house .
    	  }
    	  UNION {
          	?incumbency parl:seatIncumbencyHasHouseSeat ?seat .
          	?seat parl:houseSeatHasHouse ?house .
    	  }

        FILTER regex(str(?listAs), \"^#{letter}\", 'i') .
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
    "PREFIX parl: <http://id.ukpds.org/schema/>
     CONSTRUCT {
        ?person
        	  a parl:Person ;
            parl:personGivenName ?givenName ;
            parl:personFamilyName ?familyName ;
            <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs ;
            <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs ;
        	  parl:partyMemberHasPartyMembership ?partyMembership ;
            parl:memberHasIncumbency ?incumbency .
    	  ?house
        	  a parl:House ;
        	  parl:houseName ?houseName .
    	  ?seatIncumbency
            a parl:SeatIncumbency ;
        	  parl:incumbencyStartDate ?incumbencyStartDate ;
            parl:seatIncumbencyHasHouseSeat ?seat .
    	  ?houseIncumbency
            a parl:HouseIncumbency ;
        	  parl:incumbencyStartDate ?incumbencyStartDate ;
            parl:houseIncumbencyHasHouse ?house .
        ?seat
            a parl:HouseSeat ;
            parl:houseSeatHasConstituencyGroup ?constituency .
    	  ?partyMembership
        	  a parl:PartyMembership ;
        	  parl:partyMembershipHasParty ?party .
    	  ?party
        	  a parl:Party ;
        	  parl:partyName ?partyName .
        ?constituency
        	a parl:ConstituencyGroup ;
        	parl:constituencyGroupName ?constituencyName .
      }
      WHERE {
        BIND(<#{DATA_URI_PREFIX}/#{id}> AS ?house)

        ?house a parl:House ;
               parl:houseName ?houseName .
    	  ?person a parl:Member .
    	  ?person parl:partyMemberHasPartyMembership ?partyMembership .
    	  FILTER NOT EXISTS { ?partyMembership a parl:PastPartyMembership . }
    	  ?partyMembership parl:partyMembershipHasParty ?party .
    	  ?party parl:partyName ?partyName .
    	  ?incumbency parl:incumbencyHasMember ?person ;
       			       parl:incumbencyStartDate ?incumbencyStartDate .
    	  FILTER NOT EXISTS { ?incumbency a parl:PastIncumbency . }

    	  {
    	      ?incumbency parl:houseIncumbencyHasHouse ?house .
            BIND(?incumbency AS ?houseIncumbency)
    	  }

    	  UNION {
        	?incumbency parl:seatIncumbencyHasHouseSeat ?seat .
        	?seat parl:houseSeatHasHouse ?house .
        	?seat parl:houseSeatHasConstituencyGroup ?constituency .
        	?constituency parl:constituencyGroupName ?constituencyName .
          BIND(?incumbency AS ?seatIncumbency)
    	  }

        OPTIONAL { ?person parl:personGivenName ?givenName . }
        OPTIONAL { ?person parl:personFamilyName ?familyName . }
        OPTIONAL { ?person <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs } .
        ?person <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs .
      }"
  end

  def self.current_members_by_letter(id, letter)
    "PREFIX parl: <http://id.ukpds.org/schema/>
     CONSTRUCT {
        ?person
        	  a parl:Person ;
            parl:personGivenName ?givenName ;
            parl:personFamilyName ?familyName ;
            <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs ;
            <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs ;
        	  parl:partyMemberHasPartyMembership ?partyMembership ;
            parl:memberHasIncumbency ?incumbency .
    	  ?house
        	  a parl:House ;
        	  parl:houseName ?houseName .
    	  ?seatIncumbency
            a parl:SeatIncumbency ;
        	  parl:incumbencyStartDate ?incumbencyStartDate ;
            parl:seatIncumbencyHasHouseSeat ?seat .
    	  ?houseIncumbency
            a parl:HouseIncumbency ;
        	  parl:incumbencyStartDate ?incumbencyStartDate ;
            parl:houseIncumbencyHasHouse ?house .
        ?seat
            a parl:HouseSeat ;
            parl:houseSeatHasConstituencyGroup ?constituency .
    	  ?partyMembership
        	  a parl:PartyMembership ;
        	  parl:partyMembershipHasParty ?party .
    	  ?party
        	  a parl:Party ;
        	  parl:partyName ?partyName .
        ?constituency
        	a parl:ConstituencyGroup ;
        	parl:constituencyGroupName ?constituencyName .
      }
      WHERE {
        BIND(<#{DATA_URI_PREFIX}/#{id}> AS ?house)

        ?house a parl:House ;
               parl:houseName ?houseName .
    	  ?person a parl:Member .
    	  ?person parl:partyMemberHasPartyMembership ?partyMembership .
    	  FILTER NOT EXISTS { ?partyMembership a parl:PastPartyMembership . }
    	  ?partyMembership parl:partyMembershipHasParty ?party .
    	  ?party parl:partyName ?partyName .
    	  ?incumbency parl:incumbencyHasMember ?person ;
       			       parl:incumbencyStartDate ?incumbencyStartDate .
    	  FILTER NOT EXISTS { ?incumbency a parl:PastIncumbency . }

    	  {
    	      ?incumbency parl:houseIncumbencyHasHouse ?house .
            BIND(?incumbency AS ?houseIncumbency)
    	  }

    	  UNION {
        	?incumbency parl:seatIncumbencyHasHouseSeat ?seat .
        	?seat parl:houseSeatHasHouse ?house .
        	?seat parl:houseSeatHasConstituencyGroup ?constituency .
        	?constituency parl:constituencyGroupName ?constituencyName .
          BIND(?incumbency AS ?seatIncumbency)
    	  }

        OPTIONAL { ?person parl:personGivenName ?givenName . }
        OPTIONAL { ?person parl:personFamilyName ?familyName . }
        OPTIONAL { ?person <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs } .
        ?person <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs .

        FILTER regex(str(?listAs), \"^#{letter}\", 'i') .
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
    "PREFIX parl: <http://id.ukpds.org/schema/>
     CONSTRUCT {
        ?house
        	a parl:House ;
        	parl:houseName ?houseName .
        ?party
          a parl:Party ;
          parl:partyName ?partyName ;
    	    parl:count ?memberCount .
      }
       WHERE {
        SELECT ?party ?house ?houseName ?partyName (COUNT(?person) AS ?memberCount)
    	  WHERE {

          BIND(<#{DATA_URI_PREFIX}/#{id}> AS ?house)

          ?house a parl:House ;
                 parl:houseName ?houseName .
          ?person a parl:Member .
          ?incumbency parl:incumbencyHasMember ?person .
          FILTER NOT EXISTS { ?incumbency a parl:PastIncumbency . }
    		  ?person parl:partyMemberHasPartyMembership ?partyMembership .
          FILTER NOT EXISTS { ?partyMembership a parl:PastPartyMembership . }
    		  ?partyMembership parl:partyMembershipHasParty ?party .
    		  ?party parl:partyName ?partyName .

    		  {
    		      ?incumbency parl:houseIncumbencyHasHouse ?house .
    		  }

    		  UNION {
          		?incumbency parl:seatIncumbencyHasHouseSeat ?seat .
          		?seat parl:houseSeatHasHouse ?house .
    		  }
        }
        GROUP BY ?party ?house ?houseName ?partyName
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
    "PREFIX parl: <http://id.ukpds.org/schema/>
     CONSTRUCT {
    	?person
        	a parl:Person ;
        	parl:personGivenName ?givenName ;
          parl:personFamilyName ?familyName ;
          <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs ;
          <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs ;
        	parl:partyMemberHasPartyMembership ?partyMembership ;
        	parl:memberHasIncumbency ?incumbency .
    	?house
        	a parl:House ;
        	parl:houseName ?houseName .
    	?party
        	a parl:Party ;
        	parl:partyName ?partyName .
    	?partyMembership
        	a parl:PartyMembership ;
        	parl:partyMembershipStartDate ?partyMembershipStartDate ;
        	parl:partyMembershipEndDate ?partyMembershipEndDate .
    	?incumbency
        	a parl:Incumbency ;
        	parl:incumbencyStartDate ?incumbencyStartDate ;
        	parl:incumbencyEndDate ?incumbencyEndDate .
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
          ?partyMembership parl:partyMembershipStartDate ?partyMembershipStartDate .
    	    OPTIONAL { ?partyMembership parl:partyMembershipEndDate ?partyMembershipEndDate . }

    		  ?incumbency parl:incumbencyHasMember ?person ;
                    	parl:incumbencyStartDate ?startDate .
          OPTIONAL { ?incumbency parl:incumbencyEndDate ?incumbencyEndDate . }

          OPTIONAL { ?person parl:personGivenName ?givenName . }
    	    OPTIONAL { ?person parl:personFamilyName ?familyName . }
          OPTIONAL { ?person <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs } .
          ?person <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs .

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

  def self.party_members_letters(house_id, party_id, letter)
    "PREFIX parl: <http://id.ukpds.org/schema/>
      CONSTRUCT {
    	?person
        	a parl:Person ;
        	parl:personGivenName ?givenName ;
          parl:personFamilyName ?familyName ;
          <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs ;
          <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs ;
        	parl:partyMemberHasPartyMembership ?partyMembership ;
        	parl:memberHasIncumbency ?incumbency .
    	?house
        	a parl:House ;
        	parl:houseName ?houseName .
    	?party
        	a parl:Party ;
        	parl:partyName ?partyName .
    	?partyMembership
        	a parl:PartyMembership ;
        	parl:partyMembershipStartDate ?partyMembershipStartDate ;
        	parl:partyMembershipEndDate ?partyMembershipEndDate .
    	?incumbency
        	a parl:Incumbency ;
        	parl:incumbencyStartDate ?incumbencyStartDate ;
        	parl:incumbencyEndDate ?incumbencyEndDate .
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
          ?partyMembership parl:partyMembershipStartDate ?partyMembershipStartDate .
    	    OPTIONAL { ?partyMembership parl:partyMembershipEndDate ?partyMembershipEndDate . }

    		  ?incumbency parl:incumbencyHasMember ?person ;
                    	parl:incumbencyStartDate ?startDate .
          OPTIONAL { ?incumbency parl:incumbencyEndDate ?incumbencyEndDate . }

          OPTIONAL { ?person parl:personGivenName ?givenName . }
    	    OPTIONAL { ?person parl:personFamilyName ?familyName . }
          OPTIONAL { ?person <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs } .
          ?person <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs .

    			{
    			    ?incumbency parl:houseIncumbencyHasHouse ?house .
    			}

    			UNION {
        			?incumbency parl:seatIncumbencyHasHouseSeat ?seat .
        			?seat parl:houseSeatHasHouse ?house .
    			}
          FILTER regex(str(?listAs), \"^#{letter}\", 'i') .
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
    "PREFIX parl: <http://id.ukpds.org/schema/>
     CONSTRUCT {
    	?person
        	a parl:Person ;
        	parl:personGivenName ?givenName ;
          parl:personFamilyName ?familyName ;
          <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs ;
          <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs ;
        	parl:partyMemberHasPartyMembership ?partyMembership ;
        	parl:memberHasIncumbency ?incumbency .
    	?house
        	a parl:House ;
        	parl:houseName ?houseName .
    	?party
        	a parl:Party ;
        	parl:partyName ?partyName .
    	?partyMembership
        	a parl:PartyMembership ;
        	parl:partyMembershipStartDate ?partyMembershipStartDate .
    	?incumbency
        	a parl:Incumbency ;
        	parl:incumbencyStartDate ?incumbencyStartDate .
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
          FILTER NOT EXISTS { ?partyMembership a parl:PastPartyMembership . }
    		  ?partyMembership parl:partyMembershipHasParty ?party .
    		  ?party parl:partyName ?partyName .
          ?partyMembership parl:partyMembershipStartDate ?partyMembershipStartDate .

    		  ?incumbency parl:incumbencyHasMember ?person ;
                    	parl:incumbencyStartDate ?startDate .

          FILTER NOT EXISTS { ?incumbency a parl:PastIncumbency . }

          OPTIONAL { ?person parl:personGivenName ?givenName . }
    	    OPTIONAL { ?person parl:personFamilyName ?familyName . }
          OPTIONAL { ?person <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs } .
          ?person <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs .

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

  def self.current_party_members_letters(house_id, party_id, letter)
    "PREFIX parl: <http://id.ukpds.org/schema/>
      CONSTRUCT {
    	?person
        	a parl:Person ;
        	parl:personGivenName ?givenName ;
          parl:personFamilyName ?familyName ;
          <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs ;
          <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs ;
        	parl:partyMemberHasPartyMembership ?partyMembership ;
        	parl:memberHasIncumbency ?incumbency .
    	?house
        	a parl:House ;
        	parl:houseName ?houseName .
    	?party
        	a parl:Party ;
        	parl:partyName ?partyName .
    	?partyMembership
        	a parl:PartyMembership ;
        	parl:partyMembershipStartDate ?partyMembershipStartDate .
    	?incumbency
        	a parl:Incumbency ;
        	parl:incumbencyStartDate ?incumbencyStartDate .
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
          FILTER NOT EXISTS { ?partyMembership a parl:PastPartyMembership . }
    		  ?partyMembership parl:partyMembershipHasParty ?party .
    		  ?party parl:partyName ?partyName .
          ?partyMembership parl:partyMembershipStartDate ?partyMembershipStartDate .

    		  ?incumbency parl:incumbencyHasMember ?person ;
                    	parl:incumbencyStartDate ?startDate .

          FILTER NOT EXISTS { ?incumbency a parl:PastIncumbency . }

          OPTIONAL { ?person parl:personGivenName ?givenName . }
    	    OPTIONAL { ?person parl:personFamilyName ?familyName . }
          OPTIONAL { ?person <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs } .
          ?person <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs .

    			{
    			    ?incumbency parl:houseIncumbencyHasHouse ?house .
    			}

    			UNION {
        			?incumbency parl:seatIncumbencyHasHouseSeat ?seat .
        			?seat parl:houseSeatHasHouse ?house .
    			}
        }
        FILTER regex(str(?listAs), \"^#{letter}\", 'i') .
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
