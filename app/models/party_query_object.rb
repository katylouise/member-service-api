class PartyQueryObject
  extend QueryObject

  def self.all
    'PREFIX parl: <http://id.ukpds.org/schema/>
     CONSTRUCT {
        ?party
           a parl:Party ;
           parl:partyName ?partyName .
    	_:x parl:value ?firstLetter .
      }
      WHERE {
    	  { SELECT * WHERE {
              ?party
            		a parl:Party ;
            		parl:partyHasPartyMembership ?partyMembership ;
            		parl:partyName ?partyName .
          	}
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
            	parl:partyName ?partyName .
      }
      WHERE {
      	?incumbency a parl:Incumbency .
        FILTER NOT EXISTS { ?incumbency a parl:PastIncumbency . }
        ?incumbency parl:incumbencyHasMember ?person .
        ?person parl:partyMemberHasPartyMembership ?partyMembership .
        FILTER NOT EXISTS { ?partyMembership a parl:PastPartyMembership . }
        ?partyMembership parl:partyMembershipHasParty ?party .
        ?party parl:partyName ?partyName .
      }'
  end

  # Not used - can go
  def self.a_z_letters_current
    'PREFIX parl: <http://id.ukpds.org/schema/>
     CONSTRUCT {
         _:x parl:value ?firstLetter .
      }
      WHERE {
        SELECT DISTINCT ?firstLetter WHERE {
      	  ?incumbency a parl:Incumbency .
          FILTER NOT EXISTS { ?incumbency a parl:PastIncumbency . }
          ?incumbency parl:incumbencyHasMember ?person .
          ?person parl:partyMemberHasPartyMembership ?partyMembership .
          FILTER NOT EXISTS { ?partyMembership a parl:PastPartyMembership . }
          ?partyMembership parl:partyMembershipHasParty ?party .
          ?party parl:partyName ?partyName .

          BIND(ucase(SUBSTR(?partyName, 1, 1)) as ?firstLetter)
        }
      }'
  end

  def self.all_by_letter(letter)
    "PREFIX parl: <http://id.ukpds.org/schema/>
     CONSTRUCT {
        ?party
           a parl:Party ;
           parl:partyName ?partyName .
    	_:x parl:value ?firstLetter .
      }
      WHERE {
    	  { SELECT * WHERE {
              ?party
            		a parl:Party ;
            		parl:partyHasPartyMembership ?partyMembership ;
            		parl:partyName ?partyName .

              FILTER regex(str(?partyName), \"^#{letter}\", 'i') .
          	}
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

  # This will go.
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
               parl:count ?memberCount .
     }
      WHERE {
    	  SELECT ?party ?name (COUNT(?member) AS ?memberCount)
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
          }
        }
      GROUP BY ?party ?name
    }"
  end

  def self.members(id)
    "PREFIX parl: <http://id.ukpds.org/schema/>
     CONSTRUCT {
        ?party a parl:Party ;
            parl:partyName ?partyName .
        ?person a parl:Person ;
            parl:personGivenName ?givenName ;
            parl:personFamilyName ?familyName ;
            <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs ;
            <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs ;
            parl:partyMemberHasPartyMembership ?partyMembership .
        ?partyMembership a parl:PartyMembership ;
            parl:partyMembershipStartDate ?startDate ;
            parl:partyMembershipEndDate ?endDate .
      }
      WHERE {
        BIND(<#{DATA_URI_PREFIX}/#{id}> AS ?party)

        ?party a parl:Party ;
      	       parl:partyName ?partyName .

        OPTIONAL {
          ?party parl:partyHasPartyMembership ?partyMembership .
          ?partyMembership parl:partyMembershipHasPartyMember ?person .
          ?partyMembership parl:partyMembershipStartDate ?startDate .
          OPTIONAL { ?partyMembership parl:partyMembershipEndDate ?endDate . }

          OPTIONAL { ?person parl:personGivenName ?givenName . }
          OPTIONAL { ?person parl:personFamilyName ?familyName . }
          OPTIONAL { ?person <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs } .
          ?person <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs .
        }
      }"
  end

  def self.members_by_letter(id, letter)
    "PREFIX parl: <http://id.ukpds.org/schema/>
     CONSTRUCT {
        ?party a parl:Party ;
            parl:partyName ?partyName .
        ?person a parl:Person ;
            parl:personGivenName ?givenName ;
            parl:personFamilyName ?familyName ;
            <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs ;
            <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs ;
            parl:partyMemberHasPartyMembership ?partyMembership .
        ?partyMembership a parl:PartyMembership ;
            parl:partyMembershipStartDate ?startDate ;
            parl:partyMembershipEndDate ?endDate .
      }
      WHERE {
        BIND(<#{DATA_URI_PREFIX}/#{id}> AS ?party)

        ?party a parl:Party ;
      	       parl:partyName ?partyName .
        OPTIONAL {
          ?party parl:partyHasPartyMembership ?partyMembership .
          ?partyMembership parl:partyMembershipHasPartyMember ?person .
          ?partyMembership parl:partyMembershipStartDate ?startDate .
          OPTIONAL { ?partyMembership parl:partyMembershipEndDate ?endDate . }

          OPTIONAL { ?person parl:personGivenName ?givenName . }
          OPTIONAL { ?person parl:personFamilyName ?familyName . }
          OPTIONAL { ?person <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs } .
          ?person <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs .

          FILTER regex(str(?listAs), \"^#{letter}\", 'i') .
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
    "PREFIX parl: <http://id.ukpds.org/schema/>
     CONSTRUCT {
        ?party a parl:Party ;
            parl:partyName ?partyName .
        ?person a parl:Person ;
            parl:personGivenName ?givenName ;
            parl:personFamilyName ?familyName ;
            <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs ;
            <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs ;
            parl:partyMemberHasPartyMembership ?partyMembership .
        ?partyMembership a parl:PartyMembership ;
            parl:partyMembershipStartDate ?startDate .
      }
      WHERE {
        BIND(<#{DATA_URI_PREFIX}/#{id}> AS ?party)

        ?party a parl:Party ;
      	       parl:partyName ?partyName .

        OPTIONAL {
          ?party parl:partyHasPartyMembership ?partyMembership .
          FILTER NOT EXISTS { ?partyMembership a parl:PastPartyMembership . }
          ?partyMembership parl:partyMembershipHasPartyMember ?person .
          ?person parl:memberHasIncumbency ?incumbency .
          FILTER NOT EXISTS { ?incumbency a parl:PastIncumbency . }
          ?partyMembership parl:partyMembershipStartDate ?startDate .

          OPTIONAL { ?person parl:personGivenName ?givenName . }
          OPTIONAL { ?person parl:personFamilyName ?familyName . }
          OPTIONAL { ?person <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs } .
          ?person <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs .
        }
      }"
  end

  def self.current_members_by_letter(id, letter)
    "PREFIX parl: <http://id.ukpds.org/schema/>
     CONSTRUCT {
        ?party a parl:Party ;
            parl:partyName ?partyName .
        ?person a parl:Person ;
            parl:personGivenName ?givenName ;
            parl:personFamilyName ?familyName ;
            <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs ;
            <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs ;
            parl:partyMemberHasPartyMembership ?partyMembership .
        ?partyMembership a parl:PartyMembership ;
            parl:partyMembershipStartDate ?startDate .
      }
      WHERE {
        BIND(<#{DATA_URI_PREFIX}/#{id}> AS ?party)

        ?party a parl:Party ;
      	       parl:partyName ?partyName .

        OPTIONAL {
          ?party parl:partyHasPartyMembership ?partyMembership .
          FILTER NOT EXISTS { ?partyMembership a parl:PastPartyMembership . }
          ?partyMembership parl:partyMembershipHasPartyMember ?person .
          ?person parl:memberHasIncumbency ?incumbency .
          FILTER NOT EXISTS { ?incumbency a parl:PastIncumbency . }
          ?partyMembership parl:partyMembershipStartDate ?startDate .

          OPTIONAL { ?person parl:personGivenName ?givenName . }
          OPTIONAL { ?person parl:personFamilyName ?familyName . }
          OPTIONAL { ?person <http://example.com/F31CBD81AD8343898B49DC65743F0BDF> ?displayAs } .
          ?person <http://example.com/A5EE13ABE03C4D3A8F1A274F57097B6C> ?listAs .
        }
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