class CardsController < ApplicationController
  def index
    @cards = Card.order(:word)
  end

  def new
    @card = Card.new
    render 'card_form'
  end

  def create
    @card = Card.create(card_params)
    if @card.save
      @card.deck_ids = params_deck_ids

      todo = Todo.find_by(:word => @card.word)
      todo.delete if todo
      render 'show'
    else
      render 'card_form'
    end
  end

  def show
    @order = [:word, :definition, :sentence]
    @show_all = true
    begin
      if /^\d+/ =~ params[:id]
        @card = Card.find(params[:id])
      else
        @card = Card.find_by!(:word => params[:id])
      end
    rescue
      redirect_to cards_path
    end
  end

  def random
    @card = Card.weighted_sample(params[:cards].to_s)

    # The intermediate to_s is to ensure that nil gets converted as well
    @order = @card.box_order(params[:style].to_s.to_sym)

    render 'show'
  end

  def rate
    card = Card.find_by(:id => params[:id])
    rating = params[:rating].to_i
    card.update_attribute(:rating, card.rating + rating)
    render :plain => "OK"
  end

  def edit
    begin
      @card = Card.find(params[:id])
      render 'card_form'
    rescue
      redirect_to cards_path
    end
  end

  def update
    @card = Card.find(params[:id])
    if @card.update_attributes(card_params)
      @card.deck_ids = params_deck_ids
      render 'show'
    else
      render 'card_form'
    end
  end

  def import
  end

  def upload
    unless params[:yaml_file]
      render 'import'
      return
    end

    cards = YAML.load(params[:yaml_file].read).map do |c|
      c["word_type"] = c.delete("type")
      sanitize!(c)
    end
    created_cards = Card.mass_create(cards, params_deck_ids)

    created_cards.each do |c|
      todo = Todo.find_by(:word => c.word)
      todo.delete if todo
    end

    redirect_to cards_path
  end

  def pronounce
    pronunciation = Dictionaries::Cambridge.new(params[:word]).pronunciation

    if pronunciation
      render :plain => pronunciation
    else
      head :status => :not_found
    end
  end

  def search
    cards = Card.search(params[:query])

    # This is a seriously ugly hack, should refactor.
    @deck = Object.new
    @deck.define_singleton_method(:title, Proc.new { "Search Result" })
    @deck.define_singleton_method(:cards, Proc.new { cards })

    render 'decks/show'
  end

  private

  def card_params
    params.require(:card).permit(:word, :word_type, :definition, :synonyms, :antonyms, :sentence)
  end

  def sanitize!(hash)
    whitelist = [:word, :word_type, :definition, :synonyms, :antonyms, :sentence]
    hash.each do |k, v|
      if whitelist.include?(k.to_sym)
        hash[k] = v.join(',') if v.is_a? Array
      else
        hash.delete(k)
      end
    end
  end

  def params_deck_ids
    output = if params["deck_ids"]
               params["deck_ids"].map { |x| x.to_i }
             else
               []
             end

    unless params["new_decks_titles"].empty?
      tokens = params["new_decks_titles"].strip.split(/\s*,\s*/)
      output |= Deck.find_or_create(*tokens).map { |x| x.id }
    end

    output.uniq
  end
end
