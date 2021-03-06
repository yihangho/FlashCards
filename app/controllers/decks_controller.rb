class DecksController < ApplicationController
  def index
    @decks = Deck.all
  end

  def new
    @deck = Deck.new
    render 'deck_form'
  end

  def create
    @deck = Deck.create(deck_params)
    if @deck.save
      redirect_to decks_path
    else
      render 'deck_form'
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
    render 'deck_form'
  end

  def update
    @deck = Deck.find(params[:id])
    if @deck.update_attributes(deck_params)
      render 'show'
    else
      render 'deck_form'
    end
  end

  def destroy
    @deck = Deck.find(params[:id])
    @deck.delete if @deck
    redirect_to decks_path
  end

  private

  def deck_params
    params.require(:deck).permit(:title, :card_ids => [])
  end
end
