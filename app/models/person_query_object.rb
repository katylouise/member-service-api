class PersonQueryObject
  extend QueryObject

  def self.all
    "PREFIX : <http://id.ukpds.org/schema/>
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
	        ?s a :Person ;
             <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs .

          BIND(ucase(SUBSTR(?listAs, 1, 1)) as ?firstLetter)
        }
      }
}"
  end

  def self.lookup(source, id)
    "PREFIX parl: <http://id.ukpds.org/schema/>
     CONSTRUCT {
        ?person
        	a parl:Person .
      }
      WHERE {
        BIND(\"#{id}\" AS ?id)
        BIND(parl:#{source} AS ?source)

        ?person a parl:Person .
        ?person ?source ?id .
      }"
  end

  def self.all_by_letter(letter)
    "PREFIX : <http://id.ukpds.org/schema/>
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
            ?partyMembership :partyMembershipHasParty ?party .
            ?party :partyName ?partyName .
        }
        FILTER regex(str(?listAs), \"^#{letter}\", 'i') .
      }
    }
    UNION {
        SELECT DISTINCT ?firstLetter WHERE {
	        ?person a :Person ;
          			<http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs .

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
	        ?s a parl:Person .
          ?s <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs .

          BIND(ucase(SUBSTR(?listAs, 1, 1)) as ?firstLetter)
        }
      }'
  end

  def self.find(id)
    "PREFIX parl: <http://id.ukpds.org/schema/>
     PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
     CONSTRUCT {
        ?person a parl:Person ;
              parl:personDateOfBirth ?dateOfBirth ;
              parl:personGivenName ?givenName ;
              parl:personOtherNames ?otherName ;
              parl:personFamilyName ?familyName ;
        	    <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs ;
        	    <http://example.com/D79B0BAC513C4A9A87C9D5AFF1FC632F> ?fullTitle ;
              parl:partyMemberHasPartyMembership ?partyMembership ;
              parl:memberHasIncumbency ?incumbency .
     	  ?contactPoint a parl:ContactPoint ;
        	  parl:email ?email ;
        	  parl:phoneNumber ?phoneNumber ;
    		    parl:contactPointHasPostalAddress ?postalAddress .
    	  ?postalAddress a parl:PostalAddress ;
            parl:addressLine1 ?addressLine1 ;
            parl:addressLine2 ?addressLine2 ;
            parl:addressLine3 ?addressLine3 ;
            parl:addressLine4 ?addressLine4 ;
            parl:addressLine5 ?addressLine5 ;
            parl:faxNumber ?faxNumber ;
        	  parl:postCode ?postCode .
    	  ?constituency a parl:ConstituencyGroup ;
             parl:constituencyGroupName ?constituencyName .
    	  ?seatIncumbency a parl:SeatIncumbency ;
        	  	parl:incumbencyEndDate ?seatIncumbencyEndDate ;
        	  	parl:incumbencyStartDate ?seatIncumbencyStartDate ;
				      parl:seatIncumbencyHasHouseSeat ?seat ;
        		  parl:incumbencyHasContactPoint ?contactPoint .
    	  ?houseIncumbency a parl:HouseIncumbency ;
        		parl:incumbencyEndDate ?houseIncumbencyEndDate ;
        	  parl:incumbencyStartDate ?houseIncumbencyStartDate ;
        		parl:houseIncumbencyHasHouse ?house1 ;
        		parl:incumbencyHasContactPoint ?contactPoint .
        ?seat a parl:HouseSeat ;
            	parl:houseSeatHasConstituencyGroup ?constituency ;
            	parl:houseSeatHasHouse ?house2 .
    		?party a parl:Party ;
             	parl:partyName ?partyName .
    		?partyMembership a parl:PartyMembership ;
        	  	parl:partyMembershipStartDate ?partyMembershipStartDate ;
        	  	parl:partyMembershipEndDate ?partyMembershipEndDate ;
				      parl:partyMembershipHasParty ?party .
    		?house1 a parl:House ;
            	parl:houseName ?houseName1 .
        ?house2 a parl:House ;
            	parl:houseName ?houseName2 .
      }
      WHERE {
        BIND(<#{DATA_URI_PREFIX}/#{id}> AS ?person)

        ?person a parl:Person .
        OPTIONAL { ?person parl:personGivenName ?givenName } .
        OPTIONAL { ?person parl:personOtherNames ?otherName } .
        OPTIONAL { ?person parl:personFamilyName ?familyName } .
    	  OPTIONAL { ?person <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs } .
        OPTIONAL { ?person <http://example.com/D79B0BAC513C4A9A87C9D5AFF1FC632F> ?fullTitle } .
    	  OPTIONAL {
    	      ?person parl:memberHasIncumbency ?incumbency .
            OPTIONAL
        	    {
        	      ?incumbency a parl:HouseIncumbency .
                BIND(?incumbency AS ?houseIncumbency)
                ?houseIncumbency parl:houseIncumbencyHasHouse ?house1 .
            	  ?house1 parl:houseName ?houseName1 .
                ?houseIncumbency parl:incumbencyStartDate ?houseIncumbencyStartDate .
                OPTIONAL { ?houseIncumbency parl:incumbencyEndDate ?houseIncumbencyEndDate . }
        	    }
              OPTIONAL {
        	      ?incumbency a parl:SeatIncumbency .
                BIND(?incumbency AS ?seatIncumbency)
                ?seatIncumbency parl:seatIncumbencyHasHouseSeat ?seat .
            	  ?seat parl:houseSeatHasConstituencyGroup ?constituency .
    	      	  ?seat parl:houseSeatHasHouse ?house2 .
            	  ?house2 parl:houseName ?houseName2 .
            	  ?constituency parl:constituencyGroupName ?constituencyName .
                ?seatIncumbency parl:incumbencyStartDate ?seatIncumbencyStartDate .
                OPTIONAL { ?seatIncumbency parl:incumbencyEndDate ?seatIncumbencyEndDate . }
        	    }
              OPTIONAL {
        	        ?incumbency parl:incumbencyHasContactPoint ?contactPoint .
        	        OPTIONAL { ?contactPoint parl:phoneNumber ?phoneNumber . }
        	        OPTIONAL { ?contactPoint parl:email ?email . }
        	        OPTIONAL {
        	          ?contactPoint parl:contactPointHasPostalAddress ?postalAddress .
				            OPTIONAL { ?postalAddress parl:addressLine1 ?addressLine1 . }
				            OPTIONAL { ?postalAddress parl:addressLine2 ?addressLine2 . }
        	    	    OPTIONAL { ?postalAddress parl:addressLine3 ?addressLine3 . }
        	    	    OPTIONAL { ?postalAddress parl:addressLine4 ?addressLine4 . }
        	    	    OPTIONAL { ?postalAddress parl:addressLine5 ?addressLine5 . }
        	    	    OPTIONAL { ?postalAddress parl:faxNumber ?faxNumber . }
        	    	    OPTIONAL { ?postalAddress parl:postCode ?postCode . }
        	        }
    	          }
            }
            OPTIONAL {
    	        ?person parl:partyMemberHasPartyMembership ?partyMembership .
              ?partyMembership parl:partyMembershipHasParty ?party .
              ?partyMembership parl:partyMembershipStartDate ?partyMembershipStartDate .
              OPTIONAL { ?partyMembership parl:partyMembershipEndDate ?partyMembershipEndDate . }
              ?party parl:partyName ?partyName .
            }
          }"
  end

  def self.constituencies(id)
    "PREFIX parl: <http://id.ukpds.org/schema/>
     CONSTRUCT {
        ?person a parl:Person ;
              parl:personGivenName ?givenName ;
              parl:personFamilyName ?familyName ;
              <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs .
    	 ?constituency
        	  a parl:ConstituencyGroup ;
            parl:constituencyGroupName ?constituencyName ;
        	  parl:constituencyGroupStartDate ?constituencyStartDate ;
        	  parl:constituencyGroupEndDate ?constituencyEndDate .
    	  ?seat
        	  a parl:HouseSeat ;
        	  parl:houseSeatHasConstituencyGroup ?constituency .
    	  ?seatIncumbency
            a parl:SeatIncumbency ;
        	  parl:incumbencyEndDate ?seatIncumbencyEndDate ;
        	  parl:incumbencyStartDate ?seatIncumbencyStartDate ;
            parl:seatIncumbencyHasHouseSeat ?seat .
      }
      WHERE {
        BIND(<#{DATA_URI_PREFIX}/#{id}> AS ?person)

        ?person a parl:Person .
        OPTIONAL { ?person parl:personGivenName ?givenName } .
        OPTIONAL { ?person parl:personFamilyName ?familyName } .
    	  OPTIONAL { ?person <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs } .

        OPTIONAL {
    	    ?person parl:memberHasIncumbency ?seatIncumbency .
        	?seatIncumbency a parl:SeatIncumbency .
    	    ?seatIncumbency parl:seatIncumbencyHasHouseSeat ?seat .
    	    ?seat parl:houseSeatHasConstituencyGroup ?constituency .
          OPTIONAL { ?seatIncumbency parl:incumbencyEndDate ?seatIncumbencyEndDate . }
          ?seatIncumbency parl:incumbencyStartDate ?seatIncumbencyStartDate .
          ?constituency parl:constituencyGroupName ?constituencyName .
          ?constituency parl:constituencyGroupStartDate ?constituencyStartDate .
		      OPTIONAL { ?constituency parl:constituencyGroupEndDate ?constituencyEndDate . }
        }
      }"
  end

  def self.current_constituency(id)
    "PREFIX parl: <http://id.ukpds.org/schema/>
     CONSTRUCT {
        ?person
              a parl:Person ;
              parl:personGivenName ?givenName ;
              parl:personFamilyName ?familyName ;
              <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs .
    	  ?constituency
        	  a parl:ConstituencyGroup ;
            parl:constituencyGroupName ?constituencyName ;
        	  parl:constituencyGroupStartDate ?constituencyStartDate ;
            parl:constituencyGroupHasHouseSeat ?seat .
    	  ?seat
        	  a parl:HouseSeat ;
        	  parl:houseSeatHasSeatIncumbency ?seatIncumbency .
    	  ?seatIncumbency
            a parl:SeatIncumbency ;
        	  parl:incumbencyStartDate ?seatIncumbencyStartDate .
      }
      WHERE {
        BIND(<#{DATA_URI_PREFIX}/#{id}> AS ?person)

        ?person a parl:Person .
        OPTIONAL { ?person parl:personGivenName ?givenName } .
        OPTIONAL { ?person parl:personFamilyName ?familyName } .
    	  OPTIONAL { ?person <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs } .

        OPTIONAL {
    	    ?person parl:memberHasIncumbency ?seatIncumbency .
        	?seatIncumbency a parl:SeatIncumbency .
    	    FILTER NOT EXISTS { ?seatIncumbency a parl:PastIncumbency . }
    	    ?seatIncumbency parl:seatIncumbencyHasHouseSeat ?seat .
    	    ?seat parl:houseSeatHasConstituencyGroup ?constituency .
          ?seatIncumbency parl:incumbencyStartDate ?seatIncumbencyStartDate .
          ?constituency parl:constituencyGroupName ?constituencyName .
          ?constituency parl:constituencyGroupStartDate ?constituencyStartDate .
        }
      }"
  end

  def self.parties(id)
    "PREFIX parl: <http://id.ukpds.org/schema/>
     CONSTRUCT {
    	?person a parl:Person ;
              parl:personGivenName ?givenName ;
              parl:personFamilyName ?familyName ;
              <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs .
      ?party
        	  a parl:Party ;
            parl:partyName ?partyName .
    	?partyMembership
            a parl:PartyMembership ;
        	  parl:partyMembershipStartDate ?partyMembershipStartDate ;
        	  parl:partyMembershipEndDate ?partyMembershipEndDate ;
            parl:partyMembershipHasParty ?party .
       }
       WHERE {
          BIND(<#{DATA_URI_PREFIX}/#{id}> AS ?person)

          ?person a parl:Person .
          OPTIONAL { ?person parl:personGivenName ?givenName } .
          OPTIONAL { ?person parl:personFamilyName ?familyName } .
    	    OPTIONAL { ?person <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs } .

          OPTIONAL {
            ?person parl:partyMemberHasPartyMembership ?partyMembership .
            ?partyMembership parl:partyMembershipHasParty ?party .
            ?partyMembership parl:partyMembershipStartDate ?partyMembershipStartDate .
            OPTIONAL { ?partyMembership parl:partyMembershipEndDate ?partyMembershipEndDate . }
            ?party parl:partyName ?partyName .
          }
       }"
  end

  def self.current_party(id)
    "PREFIX parl: <http://id.ukpds.org/schema/>
     CONSTRUCT {
    	?person a parl:Person ;
              parl:personGivenName ?givenName ;
              parl:personFamilyName ?familyName ;
              <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs .
      ?party
        	  a parl:Party ;
            parl:partyName ?partyName ;
            parl:partyHasPartyMembership ?partyMembership .
    	?partyMembership
            a parl:PartyMembership ;
        	  parl:partyMembershipStartDate ?partyMembershipStartDate .
       }
       WHERE {
          BIND(<#{DATA_URI_PREFIX}/#{id}> AS ?person)

          ?person a parl:Person .
          OPTIONAL { ?person parl:personGivenName ?givenName } .
          OPTIONAL { ?person parl:personFamilyName ?familyName } .
    	    OPTIONAL { ?person <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs } .

          OPTIONAL {
            ?person parl:partyMemberHasPartyMembership ?partyMembership .
    	      FILTER NOT EXISTS { ?partyMembership a parl:PastPartyMembership . }
            ?partyMembership parl:partyMembershipHasParty ?party .
            ?partyMembership parl:partyMembershipStartDate ?partyMembershipStartDate .
            ?party parl:partyName ?partyName .
    	    }
       }"
  end

  def self.contact_points(id)
    "PREFIX parl: <http://id.ukpds.org/schema/>
     CONSTRUCT {
        ?person
          a parl:Person ;
          parl:personGivenName ?givenName ;
          parl:personFamilyName ?familyName ;
          <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs ;
          parl:memberHasIncumbency ?incumbency .
    	  ?incumbency
        	a parl:Incumbency ;
        	parl:incumbencyHasContactPoint ?contactPoint .
        ?contactPoint
            a parl:ContactPoint ;
        	  parl:email ?email ;
        	  parl:phoneNumber ?phoneNumber ;
        	  parl:faxNumber ?faxNumber ;
    		    parl:contactPointHasPostalAddress ?postalAddress .
    	  ?postalAddress
        	  a parl:PostalAddress ;
        	  parl:addressLine1 ?addressLine1 ;
			      parl:addressLine2 ?addressLine2 ;
        	  parl:addressLine3 ?addressLine3 ;
        	  parl:addressLine4 ?addressLine4 ;
        	  parl:addressLine5 ?addressLine5 ;
        	  parl:postCode ?postCode .
      }
      WHERE {
        BIND(<#{DATA_URI_PREFIX}/#{id}> AS ?person)

        ?person a parl:Person .
    	  OPTIONAL { ?person parl:personGivenName ?givenName } .
        OPTIONAL { ?person parl:personFamilyName ?familyName } .
    	  OPTIONAL { ?person <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs } .

        OPTIONAL {
        	?person parl:memberHasIncumbency ?incumbency .
          FILTER NOT EXISTS { ?incumbency a parl:PastIncumbency . }
	        ?incumbency parl:incumbencyHasContactPoint ?contactPoint .
          OPTIONAL { ?contactPoint parl:phoneNumber ?phoneNumber . }
          OPTIONAL { ?contactPoint parl:email ?email . }
          OPTIONAL { ?contactPoint parl:faxNumber ?faxNumber . }

          OPTIONAL {
        	    ?contactPoint parl:contactPointHasPostalAddress ?postalAddress .
				      OPTIONAL { ?postalAddress parl:addressLine1 ?addressLine1 . }
				      OPTIONAL { ?postalAddress parl:addressLine2 ?addressLine2 . }
        		  OPTIONAL { ?postalAddress parl:addressLine3 ?addressLine3 . }
        		  OPTIONAL { ?postalAddress parl:addressLine4 ?addressLine4 . }
        		  OPTIONAL { ?postalAddress parl:addressLine5 ?addressLine5 . }
        		  OPTIONAL { ?postalAddress parl:postCode ?postCode . }
        	}
        }
      }"
  end

  def self.houses(id)
    "PREFIX parl: <http://id.ukpds.org/schema/>
     CONSTRUCT {
        ?person
            a parl:Person ;
            parl:personGivenName ?givenName ;
            parl:personFamilyName ?familyName ;
            <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs .
    	  ?house1
            a parl:House ;
    			  parl:houseName ?houseName1 .
        ?house2
            a parl:House ;
    			  parl:houseName ?houseName2 .
    	  ?seatIncumbency
            a parl:Incumbency ;
        	  parl:incumbencyEndDate ?incumbencyEndDate ;
        	  parl:incumbencyStartDate ?incumbencyStartDate ;
            parl:seatIncumbencyHasHouseSeat ?houseSeat .
    		?houseSeat
        		a parl:HouseSeat ;
        		parl:houseSeatHasHouse ?house1 .
    		?houseIncumbency
        		a parl:Incumbency ;
        		parl:incumbencyEndDate ?incumbencyEndDate ;
        	  parl:incumbencyStartDate ?incumbencyStartDate ;
        		parl:houseIncumbencyHasHouse ?house2 .
      }
      WHERE {
        BIND(<#{DATA_URI_PREFIX}/#{id}> AS ?person)

        ?person a parl:Person .
        OPTIONAL { ?person parl:personGivenName ?givenName } .
        OPTIONAL { ?person parl:personFamilyName ?familyName } .
    	  OPTIONAL { ?person <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs } .

        OPTIONAL {
    	     ?person parl:memberHasIncumbency ?incumbency .
           OPTIONAL { ?incumbency parl:incumbencyEndDate ?incumbencyEndDate . }
    	     ?incumbency parl:incumbencyStartDate ?incumbencyStartDate .

           OPTIONAL {
        	   ?incumbency a parl:HouseIncumbency .
             BIND(?incumbency AS ?houseIncumbency )
             ?houseIncumbency parl:houseIncumbencyHasHouse ?house2 .
             ?house2 parl:houseName ?houseName2 .
        	 }
            OPTIONAL {
        	    ?incumbency a parl:SeatIncumbency .
              BIND(?incumbency AS ?seatIncumbency )
              ?seatIncumbency parl:seatIncumbencyHasHouseSeat ?houseSeat .
            	?houseSeat parl:houseSeatHasConstituencyGroup ?constituency .
    	      	?houseSeat parl:houseSeatHasHouse ?house1 .
            	?house1 parl:houseName ?houseName1 .
            	?constituency parl:constituencyGroupName ?constituencyName .
        	  }
        }
      }"
  end

  def self.current_house(id)
    "PREFIX parl: <http://id.ukpds.org/schema/>
     CONSTRUCT {
        ?person
            a parl:Person ;
            parl:personGivenName ?givenName ;
            parl:personFamilyName ?familyName ;
            <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs .
    	  ?house
            a parl:House ;
    			  parl:houseName ?houseName ;
            parl:houseHasHouseSeat ?houseSeat ;
            parl:houseHasHouseIncumbency ?houseIncumbency .
    	  ?seatIncumbency
            a parl:SeatIncumbency ;
        	  parl:incumbencyStartDate ?incumbencyStartDate .
    		?houseSeat
        		a parl:HouseSeat ;
        		parl:houseSeatHasSeatIncumbency ?seatIncumbency .
    		?houseIncumbency
        		a parl:HouseIncumbency ;
        	  parl:incumbencyStartDate ?incumbencyStartDate .
      }
      WHERE {
        BIND(<#{DATA_URI_PREFIX}/#{id}> AS ?person)

        ?person a parl:Person .
        OPTIONAL { ?person parl:personGivenName ?givenName } .
        OPTIONAL { ?person parl:personFamilyName ?familyName } .
    	  OPTIONAL { ?person <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs } .

        OPTIONAL {
    	     ?person parl:memberHasIncumbency ?incumbency .
           FILTER NOT EXISTS { ?incumbency a parl:PastIncumbency . }
    	     ?incumbency parl:incumbencyStartDate ?incumbencyStartDate .

           OPTIONAL {
        	   ?incumbency a parl:HouseIncumbency .
             BIND(?incumbency AS ?houseIncumbency )
             ?houseIncumbency parl:houseIncumbencyHasHouse ?house .
             ?house parl:houseName ?houseName .
        	 }
            OPTIONAL {
        	    ?incumbency a parl:SeatIncumbency .
              BIND(?incumbency AS ?seatIncumbency )
              ?seatIncumbency parl:seatIncumbencyHasHouseSeat ?houseSeat .
            	?houseSeat parl:houseSeatHasConstituencyGroup ?constituency .
    	      	?houseSeat parl:houseSeatHasHouse ?house .
            	?house parl:houseName ?houseName .
            	?constituency parl:constituencyGroupName ?constituencyName .
        	  }
        }
      }"
  end

  def self.lookup_by_letters(letters)
    "PREFIX parl: <http://id.ukpds.org/schema/>
     CONSTRUCT {
        ?person
        	a parl:Person ;
         	parl:personGivenName ?givenName ;
         	parl:personFamilyName ?familyName ;
          <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs
      }
      WHERE {
        ?person a parl:Person .
        OPTIONAL { ?person parl:personGivenName ?givenName } .
        OPTIONAL { ?person parl:personFamilyName ?familyName } .
        OPTIONAL { ?person <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs } .

    	  FILTER(regex(str(?displayAs), \"#{letters}\", 'i')) .
      }"
  end
end
