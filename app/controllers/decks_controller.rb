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
      @cards = Card.all
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

  def edit
    @deck = Deck.find(params[:id])
  end

  def update
    @deck = Deck.find(params[:id])
    if @deck.update_attributes(deck_params)
      @deck.card_ids = selected_cards_ids
      render 'show'
    else
      render 'edit'
    end
  end

  def destroy
    @deck = Deck.find(params[:id])
    @deck.delete if @deck
    redirect_to decks_path
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
