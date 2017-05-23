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

  def show
    id = params[:id]
    query = ParliamentQueryObject.find(id)
    response_streamer(query)
  end

  def members
    id = params[:parliament_id]
    query = ParliamentQueryObject.members(id)
    response_streamer(query)
  end
end
