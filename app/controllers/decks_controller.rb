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
      redirect_to decks_path
    else
      render 'new'
    end
  end

  private

  def deck_params
    params.require(:deck).permit(:title)
  end
end
