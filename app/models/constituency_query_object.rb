class ConstituencyQueryObject
  extend QueryObject

  def self.all
    'PREFIX : <http://id.ukpds.org/schema/>
CONSTRUCT {
    ?constituencyGroup
        a :ConstituencyGroup ;
        :constituencyGroupName ?name ;
        :constituencyGroupEndDate ?endDate ;
        :constituencyGroupHasHouseSeat ?seat .
    ?seat
        a :HouseSeat ;
        :houseSeatHasSeatIncumbency ?seatIncumbency .
    ?seatIncumbency
        a :SeatIncumbency ;
        :incumbencyHasMember ?member ;
        :incumbencyHasEndDate ?seatIncumbencyEndDate .
    ?member
        a :Person;
        :personGivenName ?givenName ;
        :personFamilyName ?familyName ;
        <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs ;
        :partyMemberHasPartyMembership ?partyMembership .
    ?partyMembership
        a :PartyMembership ;
        :partyMembershipHasParty ?party .
    ?party
        a :Party ;
        :partyName ?partyName .
    _:x
        :value ?firstLetter .
      }
    WHERE {
    	{ SELECT * WHERE {
            ?constituencyGroup a :ConstituencyGroup ;
                                :constituencyGroupName ?name .
            OPTIONAL { ?constituencyGroup :constituencyGroupEndDate ?endDate . }
            OPTIONAL {
                ?constituencyGroup :constituencyGroupHasHouseSeat ?seat .
                ?seat :houseSeatHasSeatIncumbency ?seatIncumbency .
                OPTIONAL { ?seatIncumbency :incumbencyHasEndDate ?seatIncumbencyEndDate . }
                FILTER NOT EXISTS {?seatIncumbency a :PastIncumbency . }
                ?seatIncumbency :incumbencyHasMember ?member .
                OPTIONAL { ?member :personGivenName ?givenName . }
                OPTIONAL { ?member :personFamilyName ?familyName . }
                OPTIONAL { ?member <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs } .
                ?member :partyMemberHasPartyMembership ?partyMembership .
                ?partyMembership :partyMembershipHasParty ?party .
                ?party :partyName ?partyName .
           }
        }
    }
    UNION {
		    SELECT DISTINCT ?firstLetter WHERE {
	            ?s a :ConstituencyGroup ;
                    :constituencyGroupName ?constituencyName .

                BIND(ucase(SUBSTR(?constituencyName, 1, 1)) as ?firstLetter)
            }
	    }
   }'
  end

  def self.all_by_letter(letter)
    "PREFIX : <http://id.ukpds.org/schema/>
PREFIX parl: <http://id.ukpds.org/schema/>
CONSTRUCT{
    ?constituencyGroup
        a :ConstituencyGroup ;
        :constituencyGroupName ?name ;
        :constituencyGroupEndDate ?endDate ;
        :constituencyGroupHasHouseSeat ?seat .
    ?seat
        a :HouseSeat ;
        :houseSeatHasSeatIncumbency ?seatIncumbency .
    ?seatIncumbency
        a :SeatIncumbency ;
        :incumbencyHasMember ?member ;
        :incumbencyHasEndDate ?seatIncumbencyEndDate .
    ?member
        a :Person;
        :personGivenName ?givenName ;
        :personFamilyName ?familyName ;
        <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs ;
        :partyMemberHasPartyMembership ?partyMembership .
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
        ?constituencyGroup a :ConstituencyGroup .
        OPTIONAL { ?constituencyGroup :constituencyGroupName ?name . }
        OPTIONAL { ?constituencyGroup :constituencyGroupEndDate ?endDate . }
        OPTIONAL {
            ?constituencyGroup :constituencyGroupHasHouseSeat ?seat .
            ?seat :houseSeatHasSeatIncumbency ?seatIncumbency .
            OPTIONAL { ?seatIncumbency :incumbencyHasEndDate ?seatIncumbencyEndDate . }
            FILTER NOT EXISTS {?seatIncumbency a :PastIncumbency . }
            ?seatIncumbency :incumbencyHasMember ?member .
            OPTIONAL { ?member :personGivenName ?givenName . }
            OPTIONAL { ?member :personFamilyName ?familyName . }
            OPTIONAL { ?member <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs } .
            ?member :partyMemberHasPartyMembership ?partyMembership .
            ?partyMembership :partyMembershipHasParty ?party .
            ?party :partyName ?partyName .
        }
        FILTER STRSTARTS(LCASE(?name), LCASE(\"#{letter}\"))
       }
    }
    UNION {
		SELECT DISTINCT ?firstLetter WHERE {
	        ?s a :ConstituencyGroup ;
          		:constituencyGroupName ?constituencyName .

          	BIND(ucase(SUBSTR(?constituencyName, 1, 1)) as ?firstLetter)
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
	        ?s a parl:ConstituencyGroup .
          ?s parl:constituencyGroupName ?constituencyName .

          BIND(ucase(SUBSTR(?constituencyName, 1, 1)) as ?firstLetter)
        }
      }'
  end

  def self.lookup(source, id)
    "PREFIX parl: <http://id.ukpds.org/schema/>
     CONSTRUCT {
        ?constituency
           a parl:ConstituencyGroup .
      }
      WHERE {
        BIND(\"#{id}\" AS ?id)
        BIND(parl:#{source} AS ?source)

	      ?constituency a parl:ConstituencyGroup .
        ?constituency ?source ?id .
      }"
  end

  def self.find(id)
    "PREFIX parl: <http://id.ukpds.org/schema/>
     CONSTRUCT{
          ?constituencyGroup
            a parl:ConstituencyGroup ;
            parl:constituencyGroupEndDate ?endDate ;
            parl:constituencyGroupStartDate ?startDate ;
         		parl:constituencyGroupName ?name ;
        	  parl:constituencyGroupOnsCode ?onsCode ;
            parl:constituencyGroupHasConstituencyArea ?constituencyArea .
         	?constituencyArea
            a parl:ConstituencyArea ;
            parl:constituencyAreaLatitude ?latitude ;
         		parl:constituencyAreaLongitude ?longitude ;
        	  parl:constituencyAreaExtent ?polygon .
            ?constituencyGroup parl:constituencyGroupHasHouseSeat ?houseSeat .
          ?houseSeat a parl:HouseSeat ;
                    parl:houseSeatHasSeatIncumbency ?seatIncumbency .
          ?seatIncumbency a parl:SeatIncumbency ;
                            parl:incumbencyHasMember ?member ;
                            parl:incumbencyEndDate ?seatIncumbencyEndDate ;
                            parl:incumbencyStartDate ?seatIncumbencyStartDate .
          ?member a parl:Person ;
                    parl:personGivenName ?givenName ;
                    parl:personFamilyName ?familyName ;
                    <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs .
      }
      WHERE {
          BIND( <#{DATA_URI_PREFIX}/#{id}> AS ?constituencyGroup )
          ?constituencyGroup a parl:ConstituencyGroup .
          OPTIONAL { ?constituencyGroup parl:constituencyGroupEndDate ?endDate . }
          OPTIONAL { ?constituencyGroup parl:constituencyGroupStartDate ?startDate . }
          OPTIONAL { ?constituencyGroup parl:constituencyGroupName ?name . }
    	    OPTIONAL { ?constituencyGroup parl:constituencyGroupOnsCode ?onsCode . }
          OPTIONAL {
            ?constituencyGroup parl:constituencyGroupHasConstituencyArea ?constituencyArea .
            ?constituencyArea a parl:ConstituencyArea .
            OPTIONAL { ?constituencyArea parl:constituencyAreaLatitude ?latitude . }
            OPTIONAL { ?constituencyArea parl:constituencyAreaLongitude ?longitude . }
            OPTIONAL { ?constituencyArea parl:constituencyAreaExtent ?polygon . }
          }
          OPTIONAL {
            ?constituencyGroup parl:constituencyGroupHasHouseSeat ?houseSeat .
            ?houseSeat parl:houseSeatHasSeatIncumbency ?seatIncumbency .
      	    ?seatIncumbency a parl:SeatIncumbency ;
            OPTIONAL { ?seatIncumbency parl:incumbencyHasMember ?member . }
            OPTIONAL { ?seatIncumbency parl:incumbencyEndDate ?seatIncumbencyEndDate . }
            OPTIONAL { ?seatIncumbency parl:incumbencyStartDate ?seatIncumbencyStartDate . }
            OPTIONAL { ?member parl:personGivenName ?givenName . }
            OPTIONAL { ?member parl:personFamilyName ?familyName . }
            OPTIONAL { ?member <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs } .
          }
      }"
  end

  def self.all_current
    'PREFIX : <http://id.ukpds.org/schema/>
PREFIX parl: <http://id.ukpds.org/schema/>
CONSTRUCT{
    ?constituencyGroup
        a :ConstituencyGroup ;
        :constituencyGroupName ?name ;
        :constituencyGroupHasHouseSeat ?seat .
    ?seat
        a :HouseSeat ;
        :houseSeatHasSeatIncumbency ?seatIncumbency .
    ?seatIncumbency
        a :SeatIncumbency ;
        :incumbencyHasMember ?member .
    ?member
        a :Person ;
        :personGivenName ?givenName ;
        :personFamilyName ?familyName ;
        <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs ;
        :partyMemberHasPartyMembership ?partyMembership .
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
        ?constituencyGroup a :ConstituencyGroup .
        FILTER NOT EXISTS { ?constituencyGroup a :PastConstituencyGroup . }
        OPTIONAL { ?constituencyGroup :constituencyGroupName ?name . }
        OPTIONAL {
            ?constituencyGroup :constituencyGroupHasHouseSeat ?seat .
            ?seat :houseSeatHasSeatIncumbency ?seatIncumbency .
            FILTER NOT EXISTS { ?seatIncumbency a :PastIncumbency . }
            ?seatIncumbency :incumbencyHasMember ?member .
            OPTIONAL { ?member :personGivenName ?givenName . }
            OPTIONAL { ?member :personFamilyName ?familyName . }
            OPTIONAL { ?member <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs } .
            ?member :partyMemberHasPartyMembership ?partyMembership .
            ?partyMembership :partyMembershipHasParty ?party .
            ?party :partyName ?partyName .
        }
      }
    }
    UNION {
          SELECT DISTINCT ?firstLetter WHERE {
	        ?s a :ConstituencyGroup .
          	FILTER NOT EXISTS { ?s a :PastConstituencyGroup . }
          	?s :constituencyGroupName ?constituencyName .

          	BIND(ucase(SUBSTR(?constituencyName, 1, 1)) as ?firstLetter)
        }
      }

}'
  end

  def self.all_current_by_letter(letter)
    "PREFIX : <http://id.ukpds.org/schema/>
CONSTRUCT{
    ?constituencyGroup
        a :ConstituencyGroup ;
        :constituencyGroupName ?name ;
        :constituencyGroupHasHouseSeat ?seat .
    ?seat
        a :HouseSeat ;
        :houseSeatHasSeatIncumbency ?seatIncumbency .
    ?seatIncumbency
        a :SeatIncumbency ;
        :incumbencyHasMember ?member .
    ?member
        a :Person ;
        :personGivenName ?givenName ;
        :personFamilyName ?familyName ;
        <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs ;
        :partyMemberHasPartyMembership ?partyMembership .
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
        ?constituencyGroup a :ConstituencyGroup .
        FILTER NOT EXISTS { ?constituencyGroup a :PastConstituencyGroup . }
        OPTIONAL { ?constituencyGroup :constituencyGroupName ?name . }
        OPTIONAL {
            ?constituencyGroup :constituencyGroupHasHouseSeat ?seat .
            ?seat :houseSeatHasSeatIncumbency ?seatIncumbency .
            FILTER NOT EXISTS { ?seatIncumbency a :PastIncumbency . }
            ?seatIncumbency :incumbencyHasMember ?member .
            OPTIONAL { ?member :personGivenName ?givenName . }
            OPTIONAL { ?member :personFamilyName ?familyName . }
            OPTIONAL { ?member <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs } .
            ?member :partyMemberHasPartyMembership ?partyMembership .
            ?partyMembership :partyMembershipHasParty ?party .
            ?party :partyName ?partyName .
        }
        FILTER STRSTARTS(LCASE(?name), LCASE(\"#{letter}\"))
      }
    }
    UNION {
        SELECT DISTINCT ?firstLetter WHERE {
          ?s a :ConstituencyGroup .
              FILTER NOT EXISTS { ?s a :PastConstituencyGroup . }
          ?s :constituencyGroupName ?constituencyName .

          BIND(ucase(SUBSTR(?constituencyName, 1, 1)) as ?firstLetter)
        }
      }
}"
  end

  def self.a_z_letters_current
    'PREFIX parl: <http://id.ukpds.org/schema/>
     CONSTRUCT {
         _:x parl:value ?firstLetter .
      }
      WHERE {
        SELECT DISTINCT ?firstLetter WHERE {
	        ?s a parl:ConstituencyGroup .
          FILTER NOT EXISTS { ?s a parl:PastConstituencyGroup . }
          ?s parl:constituencyGroupName ?constituencyName .

          BIND(ucase(SUBSTR(?constituencyName, 1, 1)) as ?firstLetter)
        }
      }'
  end

  def self.members(id)
    "PREFIX parl: <http://id.ukpds.org/schema/>
     CONSTRUCT{
    	   	?constituencyGroup
            a parl:ConstituencyGroup ;
         		parl:constituencyGroupName ?name ;
         		parl:constituencyGroupHasHouseSeat ?houseSeat ;
            parl:constituencyGroupStartDate ?constituencyGroupStartDate ;
            parl:constituencyGroupEndDate ?constituencyGroupEndDate .
         	?houseSeat a parl:HouseSeat ;
            parl:houseSeatHasSeatIncumbency ?seatIncumbency .
    	  	?seatIncumbency a parl:SeatIncumbency ;
                          parl:incumbencyHasMember ?member ;
          					      parl:incumbencyEndDate ?seatIncumbencyEndDate ;
        					        parl:incumbencyStartDate ?seatIncumbencyStartDate .
        	?member a parl:Person ;
                  parl:personGivenName ?givenName ;
        			    parl:personFamilyName ?familyName ;
                  <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs .
      }
      WHERE {
        BIND( <#{DATA_URI_PREFIX}/#{id}> AS ?constituencyGroup )

        ?constituencyGroup a parl:ConstituencyGroup ;
    	                    parl:constituencyGroupHasHouseSeat ?houseSeat .
    	  OPTIONAL { ?constituencyGroup parl:constituencyGroupName ?name . }
        OPTIONAL { ?constituencyGroup parl:constituencyGroupEndDate ?constituencyGroupEndDate . }
        OPTIONAL { ?constituencyGroup parl:constituencyGroupStartDate ?constituencyGroupStartDate . }
    	  OPTIONAL {
          ?houseSeat parl:houseSeatHasSeatIncumbency ?seatIncumbency .
          OPTIONAL {
    	      ?seatIncumbency parl:incumbencyHasMember ?member .
              OPTIONAL { ?seatIncumbency parl:incumbencyEndDate ?seatIncumbencyEndDate . }
        	    OPTIONAL { ?seatIncumbency parl:incumbencyStartDate ?seatIncumbencyStartDate . }
        	    OPTIONAL { ?member parl:personGivenName ?givenName . }
        	    OPTIONAL { ?member parl:personFamilyName ?familyName . }
              OPTIONAL { ?member <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs } .
          }
        }
      }"
  end

  def self.current_member(id)
    "PREFIX parl: <http://id.ukpds.org/schema/>
     CONSTRUCT{
    	   	?constituencyGroup
            	a parl:ConstituencyGroup ;
         		  parl:constituencyGroupName ?name ;
              parl:constituencyGroupStartDate ?constituencyGroupStartDate ;
              parl:constituencyGroupEndDate ?constituencyGroupEndDate ;
         		  parl:constituencyGroupHasHouseSeat ?houseSeat .
         	?houseSeat a parl:HouseSeat ;
                     parl:houseSeatHasSeatIncumbency ?seatIncumbency .
    	  	?seatIncumbency a parl:SeatIncumbency ;
                          parl:incumbencyHasMember ?member ;
          				        parl:incumbencyEndDate ?seatIncumbencyEndDate ;
        					        parl:incumbencyStartDate ?seatIncumbencyStartDate .
        	?member a parl:Person ;
                  parl:personGivenName ?givenName ;
        			    parl:personFamilyName ?familyName ;
                  <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs .
      }
      WHERE {
        BIND( <#{DATA_URI_PREFIX}/#{id}> AS ?constituencyGroup )

        ?constituencyGroup a parl:ConstituencyGroup ;
    	                     parl:constituencyGroupHasHouseSeat ?houseSeat .
    	  OPTIONAL { ?constituencyGroup parl:constituencyGroupName ?name . }
        OPTIONAL { ?constituencyGroup parl:constituencyGroupStartDate ?constituencyGroupStartDate . }
        OPTIONAL { ?constituencyGroup parl:constituencyGroupEndDate ?constituencyGroupEndDate . }
    	  OPTIONAL {
          ?houseSeat parl:houseSeatHasSeatIncumbency ?seatIncumbency .
          FILTER NOT EXISTS { ?seatIncumbency a parl:PastIncumbency . }
          OPTIONAL {
    	      ?seatIncumbency parl:incumbencyHasMember ?member .
            OPTIONAL { ?seatIncumbency parl:incumbencyEndDate ?seatIncumbencyEndDate . }
        	  OPTIONAL { ?seatIncumbency parl:incumbencyStartDate ?seatIncumbencyStartDate . }
        	  OPTIONAL { ?member parl:personGivenName ?givenName . }
        	  OPTIONAL { ?member parl:personFamilyName ?familyName . }
            OPTIONAL { ?member <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs } .
          }
        }
      }"
  end

  def self.contact_point(id)
    "PREFIX parl: <http://id.ukpds.org/schema/>
     CONSTRUCT {
      	?constituencyGroup a parl:ConstituencyGroup ;
        				parl:constituencyGroupHasHouseSeat ?houseSeat ;
        				parl:constituencyGroupName ?name .
        ?houseSeat a parl:HouseSeat ;
                parl:houseSeatHasSeatIncumbency ?incumbency .
    	  ?incumbency a parl:SeatIncumbency ;
                parl:incumbencyHasContactPoint ?contactPoint .
        ?contactPoint a parl:ContactPoint ;
        			  parl:email ?email ;
                parl:phoneNumber ?phoneNumber ;
        			  parl:faxNumber ?faxNumber ;
    			      parl:contactForm ?contactForm ;
    	          parl:contactPointHasPostalAddress ?postalAddress .
        ?postalAddress a parl:PostalAddress ;
        			 parl:postCode ?postCode ;
       				 parl:addressLine1 ?addressLine1 ;
    				   parl:addressLine2 ?addressLine2 ;
    				   parl:addressLine3 ?addressLine3 ;
    				   parl:addressLine4 ?addressLine4 ;
    				   parl:addressLine5 ?addressLine5 .
      }
      WHERE {
    	BIND( <#{DATA_URI_PREFIX}/#{id}> AS ?constituencyGroup )

      ?constituencyGroup a parl:ConstituencyGroup .
      	 OPTIONAL {
        	?constituencyGroup parl:constituencyGroupHasHouseSeat ?houseSeat .
        	OPTIONAL {
        		?houseSeat parl:houseSeatHasSeatIncumbency ?incumbency .
        		FILTER NOT EXISTS { ?incumbency a parl:PastIncumbency . }
        		OPTIONAL {
            		?incumbency parl:incumbencyHasContactPoint ?contactPoint .
                    OPTIONAL{ ?contactPoint parl:email ?email . }
                    OPTIONAL{ ?contactPoint parl:phoneNumber ?phoneNumber . }
                    OPTIONAL{ ?contactPoint parl:faxNumber ?faxNumber . }
                    OPTIONAL{ ?contactPoint parl:contactForm ?contactForm . }
                    OPTIONAL{ ?contactPoint parl:contactPointHasPostalAddress ?postalAddress .
                        OPTIONAL{ ?postalAddress parl:postCode ?postCode . }
                        OPTIONAL{ ?postalAddress parl:addressLine1 ?addressLine1 . }
                        OPTIONAL{ ?postalAddress parl:addressLine2 ?addressLine2 . }
                        OPTIONAL{ ?postalAddress parl:addressLine3 ?addressLine3 . }
                        OPTIONAL{ ?postalAddress parl:addressLine4 ?addressLine4 . }
                        OPTIONAL{ ?postalAddress parl:addressLine5 ?addressLine5 . }
                    }
                }
        		}
    		}
        OPTIONAL { ?constituencyGroup parl:constituencyGroupName ?name . }
      }"
  end

  def self.lookup_by_letters(letters)
    "PREFIX parl: <http://id.ukpds.org/schema/>
     CONSTRUCT {
        ?constituency
        	a parl:ConstituencyGroup ;
         	parl:constituencyGroupName ?constituencyName ;
          parl:constituencyGroupEndDate ?endDate .
      }
      WHERE {
        ?constituency a parl:ConstituencyGroup .
        ?constituency parl:constituencyGroupName ?constituencyName .
        OPTIONAL { ?constituency parl:constituencyGroupEndDate ?endDate . }

    	  FILTER(regex(str(?constituencyName), \"#{letters}\", 'i')) .
      }"
  end
end