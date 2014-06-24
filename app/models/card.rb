class Card < ActiveRecord::Base
  has_and_belongs_to_many :decks
  validates :word, :presence => true

  # condition can be one of the following:
  #
  # - A positive integer, :id. Map to the ID of a Card. Example, 10.
  # - A negative integer, -:count. Select the newest :count cards. Example, -5
  # - A range, :start-:end. Select cards with IDs in that range. Example, 1-10
  # - "score :op :score". Select cards with scores :op :score, where :op is one
  #   of >, >=, <, <= or =, and :score is an integer.
  # - Anything else. First, look for Decks with this name, then look for Cards
  #   with this word.
  # Always return an Array
  def self.smart_find(condition)
    case condition.to_s
    when /^(\d+)$/
      [find_by(:id => $1)].delete_if { |x| x.nil? }
    when /^\-(\d+)$/
      last($1)
    when /^(\d+)\-(\d+)$/
      where("id >= #{$1} AND id <= #{$2}").to_a
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

  # weighted_random_order_score is the relative likelyhood of any instance being
  # picked. Essentially, it is the product of hours since last revised * difference in rating between itself and the best performed card.
  # The probability of this card being chosen is score/total score.
  def weighted_random_order_score(now = Time.now, max_score = nil)
    hours = ((now - updated_at.to_time)/3600).ceil
    max_score = Card.order(:rating => :desc).take.rating if max_score.nil?
    ((max_score + 1 - rating) ** 1.5).ceil * hours
  end
end
