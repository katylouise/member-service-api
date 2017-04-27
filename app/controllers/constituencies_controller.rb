class ConstituenciesController < ApplicationController
  def index
    query = ConstituencyQueryObject.all
    response_streamer(query)
  end

  def lookup
    source = params['source']
    id = params['id']
    query = ConstituencyQueryObject.lookup(source, id)
    response_streamer(query)
  end

  def show
    constituency_id = params[:constituency]
    query = ConstituencyQueryObject.find(constituency_id)
    response_streamer(query)
  end

  def current
    query = ConstituencyQueryObject.all_current
    response_streamer(query)
  end

  def members
    constituency_id = params[:constituency_id]
    query = ConstituencyQueryObject.members(constituency_id)
    response_streamer(query)
  end

  def current_member
    constituency_id = params[:constituency_id]
    query = ConstituencyQueryObject.current_member(constituency_id)
    response_streamer(query)
  end

  def contact_point
    constituency_id = params[:constituency_id]
    query = ConstituencyQueryObject.contact_point(constituency_id)
    response_streamer(query)
  end

  def letters
    letter = params[:letter]
    query = ConstituencyQueryObject.all_by_letter(letter)
    response_streamer(query)
  end

  def a_z_letters
    query = ConstituencyQueryObject.a_z_letters
    response_streamer(query)
  end

  def current_letters
    letter = params[:letter]
    query = ConstituencyQueryObject.all_current_by_letter(letter)
    response_streamer(query)
  end

  def a_z_letters_current
    query = ConstituencyQueryObject.a_z_letters_current
    response_streamer(query)
  end

  def lookup_by_letters
    letters = params[:letters]
    query = ConstituencyQueryObject.lookup_by_letters(letters)
    response_streamer(query)
  end
end