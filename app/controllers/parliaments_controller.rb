class ParliamentsController < ApplicationController
  def index
    query = ParliamentQueryObject.all
    response_streamer(query)
  end

  def current
    query = ParliamentQueryObject.current
    response_streamer(query)
  end

  def previous
    query = ParliamentQueryObject.previous
    response_streamer(query)
  end

  def next
    query = ParliamentQueryObject.next
    response_streamer(query)
  end

  def lookup
    source = params['source']
    id = params['id']
    query = ParliamentQueryObject.lookup(source, id)
    response_streamer(query)
  end

  def show
    id = params[:parliament]
    query = ParliamentQueryObject.find(id)
    response_streamer(query)
  end

  def next_parliament
    id = params[:parliament_id]
    query = ParliamentQueryObject.next_parliament(id)
    response_streamer(query)
  end

  def previous_parliament
    id = params[:parliament_id]
    query = ParliamentQueryObject.previous_parliament(id)
    response_streamer(query)
  end

  def members
    id = params[:parliament_id]
    query = ParliamentQueryObject.members(id)
    response_streamer(query)
  end

  def members_letters
    id = params[:parliament_id]
    letter = params[:letter]
    query = ParliamentQueryObject.members_letters(id, letter)
    response_streamer(query)
  end

  def a_z_letters_members
    id = params[:parliament_id]
    query = ParliamentQueryObject.members_a_z_letters(id)
    response_streamer(query)
  end

  def members_houses
    id = params[:parliament_id]
    query = ParliamentQueryObject.members_houses(id)
    response_streamer(query)
  end

  def members_house
    parliament_id = params[:parliament_id]
    house_id = params[:house_id]
    query = ParliamentQueryObject.members_house(parliament_id, house_id)
    response_streamer(query)
  end

  def a_z_letters_members_house
    parliament_id = params[:parliament_id]
    house_id = params[:house_id]
    query = ParliamentQueryObject.members_house_a_z_letters(parliament_id, house_id)
    response_streamer(query)
  end

  def members_house_letters
    parliament_id = params[:parliament_id]
    house_id = params[:house_id]
    letter = params[:letter]
    query = ParliamentQueryObject.members_house_letters(parliament_id, house_id, letter)
    response_streamer(query)
  end

  def parties
    id = params[:parliament_id]
    query = ParliamentQueryObject.parties(id)
    response_streamer(query)
  end

  def party
    parliament_id = params[:parliament_id]
    party_id = params[:party_id]
    query = ParliamentQueryObject.party(parliament_id, party_id)
    response_streamer(query)
  end

  def party_members
    parliament_id = params[:parliament_id]
    party_id = params[:party_id]
    query = ParliamentQueryObject.party_members(parliament_id, party_id)
    response_streamer(query)
  end

  def a_z_letters_party_members
    parliament_id = params[:parliament_id]
    party_id = params[:party_id]
    query = ParliamentQueryObject.party_members_a_z_letters(parliament_id, party_id)
    response_streamer(query)
  end

  def party_members_letters
    parliament_id = params[:parliament_id]
    party_id = params[:party_id]
    letter = params[:letter]
    query = ParliamentQueryObject.party_members_letters(parliament_id, party_id, letter)
    response_streamer(query)
  end
end
