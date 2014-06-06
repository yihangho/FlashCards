class CardsController < ApplicationController
  def index
    @cards = Card.all
  end

  def new
    @card = Card.new
  end

  def create
    @card = Card.create(card_params)
    if @card.save
      render 'show'
    else
      render 'new'
    end
  end

  def show
    @card = Card.find_by(:id => params[:id])
  end

  private

  def card_params
    params.require(:card).permit(:word, :word_type, :definition, :synonyms, :antonyms, :sentence)
  end
end
