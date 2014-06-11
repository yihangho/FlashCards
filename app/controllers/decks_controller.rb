class DecksController < ApplicationController
  def index
    @decks = Deck.all
  end

  def new
    @deck = Deck.new
    @cards = Card.all
  end

  def create
    @deck = Deck.create(deck_params)
    if @deck.save
      @deck.card_ids |= selected_cards_ids
      redirect_to decks_path
    else
      render 'new'
    end
  end

  def show
    if /^\d+$/ =~ params[:id]
      @deck = Deck.find(params[:id])
    else
      @deck = Deck.find_by!(:title => params[:id])
    end
  end

  private

  def deck_params
    params.require(:deck).permit(:title)
  end

  def selected_cards_ids
    output = []
    params.each do |k,_|
      if /^card-(?<id>\d+)$/ =~ k
        output << id.to_i
      end
    end
    output
  end
end
