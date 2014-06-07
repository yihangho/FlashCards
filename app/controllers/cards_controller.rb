class CardsController < ApplicationController
  def index
    @cards = Card.all
  end

  def new
    @card = Card.new
  end

  def create
    if params["card"]["yaml_file"]
      cards = YAML.load(params["card"]["yaml_file"].read)
      cards.each do |card|
        card["word_type"] = card.delete("type")
        sanitize!(card)
        Card.create(card).save
      end
      redirect_to cards_path
    else
      @card = Card.create(card_params)
      if @card.save
        render 'show'
      else
        render 'new'
      end
    end
  end

  def show
    @card = Card.find_by(:id => params[:id])
  end

  def random
    @card = Card.all.sample
    render 'show'
  end

  def rate
    card = Card.find_by(:id => params[:id])
    rating = params[:rating].to_i
    if card
      card.update_attribute(:rating, card.rating + rating)
    end
    render :plain => "OK"
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
end
