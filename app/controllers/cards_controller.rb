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
        todo = Todo.find_by(:word => @card.word)
        todo.delete if todo
        render 'show'
      else
        render 'new'
      end
    end
  end

  def show
    begin
      @card = Card.find(params[:id])
    rescue
      redirect_to cards_path
    end
  end

  def random
    now = Time.now
    if params[:cards].nil? || params[:cards] == "all"
      cards = Card.all
      max_rating = Card.order(:rating => :desc).take.rating
    else
      cards = []
      max_rating = -1e9
      cards_list = params[:cards].split(',').map { |x| x.strip }
      cards_list.each do |item|
        if /^\d*$/ =~ item
          result = Card.find_by(:id => item.to_i)
          cards << result if result
        elsif /^(?<first>\d+)\-(?<last>\d+)$/ =~ item
          result = Card.where("id >= #{first.to_i} AND id <= #{last.to_i}")
          cards |= result if result.any?
        elsif /^score\s*(?<op>=|\<|\<=|\>|\>=)\s*(?<score>\d+)$/ =~ item
          result = Card.where("rating #{op} #{score}")
          cards |= result if result.any?
        else
          result = Card.find_by(:word => item)
          cards << result if result
        end
      end
      cards.each { |card| max_rating = card.rating > max_rating ? card.rating : max_rating }
    end
    cards = cards.collect do |card|
      {
        :card => card,
        :score => card.weighted_random_order_score(now, max_rating)
      }
    end
    cards.each_index do |i|
      next if i == 0
      cards[i][:score] += cards[i-1][:score]
    end
    choice = (1..cards.last[:score]).to_a.sample
    @card = cards.bsearch { |card| card[:score] >= choice }[:card]

    if ["word", "definition", "sentence"].include?(params[:style])
      @order = [:word, :definition, :sentence].shuffle
      @order.delete(params[:style].to_sym)
      @order.unshift(params[:style].to_sym)
    end
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
      @card = Card.find(:params[:id])
    rescue
      redirect_to cards_path
    end
  end

  def update
    @card = Card.find(params[:id])
    if @card.update_attributes(card_params)
      render 'show'
    else
      render 'edit'
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
end
