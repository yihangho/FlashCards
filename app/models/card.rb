class Card < ActiveRecord::Base
  include ElasticSearch
  elastic_search_attributes :word, :definition, :synonyms, :antonyms, :sentence

  has_many :reviews
  has_and_belongs_to_many :decks
  validates :word, :presence => true
  validates :definition, :presence => true

  # condition can be one of the following:
  #
  # - "All" or "". Returns all Cards.
  # - A positive integer, :id. Map to the ID of a Card. Example, 10.
  # - A negative integer, -:count. Select the newest :count cards. Example, -5
  # - A range, :start-:end. Select cards with IDs in that range. Example, 1-10
  # - "score :op :score". Select cards with scores :op :score, where :op is one
  #   of >, >=, <, <= or =, and :score is an integer.
  # - Anything else. First, look for Decks with this name, then look for Cards
  #   with this word.
  # Always return an Array
  def self.smart_find(condition = nil)
    case condition.to_s.downcase
    when "all", ""
      all.to_a
    when /^(\d+)$/
      [find_by(:id => $1)].delete_if { |x| x.nil? }
    when /^\-(\d+)$/
      last($1)
    when /^(\d+)\-(\d+)$/
      where("'id' >= ? AND 'id' <= ?", $1, $2).to_a
    when /^score\s*(=|\<|\<=|\>|\>=)\s*(\d+)$/
      where("rating #{$1} #{$2}").to_a
    else
      deck = Deck.find_by(:title => condition)
      if deck
        deck.cards.to_a
      else
        [find_by(:word => condition)].delete_if { |x| x.nil? }
      end
    end
  end

  def self.weighted_sample(smart_find_params = "")
    now = Time.now

    tokens = smart_find_params.to_s.split(/\s*,\s*/)
    tokens = [nil] if tokens.length == 0

    cards = tokens.map { |t| Card.smart_find(t) }
                  .flatten
                  .uniq

    if cards.length > 1
      cards = cards.sort { |a, b| a.updated_at <=> b.updated_at }[0..-2]
    end

    max_rating = cards.max_by { |card| card.rating }.rating

    # scores is the probability density of each card
    scores = cards.map { |c| c.weighted_random_order_score(now, max_rating) }
    # cumulative_scores is the cumulative density of each card
    cumulative_scores = [scores.first]
    scores.inject do |cumulative, score|
      cumulative_scores << cumulative + score
      cumulative + score
    end

    choice = SecureRandom.random_number * cumulative_scores.last
    index = cumulative_scores.index { |s| choice <= s }
    cards[index]
  end

  def self.mass_create(cards, deck_ids = [])
    created_cards = []

    cards.each do |c|
      card = Card.new(c)
      if card.save
        card.deck_ids = deck_ids
        created_cards << card
      end
    end

    created_cards
  end

  # This is equivalent to the old rating column
  def rating
    (thumb_up_reviews_count || 0) - (thumb_down_reviews_count || 0)
  end

  # weighted_random_order_score is the relative likelihood of any instance being
  # picked. Essentially, it is the product of hours since last revised * difference in rating between itself and the best performed card.
  # The probability of this card being chosen is score/total score.
  def weighted_random_order_score(now = Time.now, max_score = nil)
    hours = ((now - updated_at.to_time)/3600).ceil
    max_score = Card.all.map(&:rating).max if max_score.nil?
    ((max_score + 1 - rating) ** 1.5).ceil * hours
  end

  def box_order(first = nil, random = true)
    order = [:word, :definition, :sentence]
    order.shuffle! if random

    if order.include?(first)
      order.delete(first)
      order.unshift(first)
    end

    # The word and definition cards are assume to be never empty.
    order.delete(:sentence) if sentence.empty?

    order
  end
end
