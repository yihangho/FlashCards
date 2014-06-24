class CardsController < ApplicationController
  def index
    @cards = Card.all
  end

  def new
    @card = Card.new
    render 'card_form'
  end

  def create
    deck_ids = params_deck_ids

    if params["card"]["yaml_file"]
      cards = YAML.load(params["card"]["yaml_file"].read)
      cards.each do |card|
        card["word_type"] = card.delete("type")
        sanitize!(card)
        card = Card.create(card)
        card.deck_ids = deck_ids if card.save
      end
      redirect_to cards_path
    else
      @card = Card.create(card_params)
      if @card.save
        @card.deck_ids = deck_ids
        todo = Todo.find_by(:word => @card.word)
        todo.delete if todo
        render 'show'
      else
        render 'card_form'
      end
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
    now = Time.now

    tokens = params[:cards].to_s.split(/\s*,\s*/)
    tokens = [nil] if tokens.length == 0

    cards = tokens.map { |t| Card.smart_find t }
                  .flatten
                  .uniq

    max_rating = cards.max_by { |card| card.rating }.rating

    scores = cards.map { |c| c.weighted_random_order_score(now, max_rating) }
    cumulative_scores = [scores.first]
    scores.inject do |cumulative, score|
      cumulative_scores << cumulative + score
      cumulative + score
    end

    choice = (1..cumulative_scores.last).to_a.sample
    index = cumulative_scores.index { |s| choice <= s }
    @card = cards[index]
    @order = @card.box_order(params[:style].to_sym)

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
      params["new_decks_titles"].strip.split(/\s*,\s*/).each do |title|
        next if title.empty?
        begin
          deck = Deck.find_by!(:title => title)
          output << deck.id
        rescue
          deck = Deck.create(:title => title)
          output << deck.id if deck.save
        end
      end
    end
    output.uniq
  end
end
