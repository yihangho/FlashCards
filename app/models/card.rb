class Card < ActiveRecord::Base
  has_and_belongs_to_many :decks
  validates :word, :presence => true

  # weighted_random_order_score is the relative likelyhood of any instance being
  # picked. Essentially, it is the product of hours since last revised * difference in rating between itself and the best performed card.
  # The probability of this card being chosen is score/total score.
  def weighted_random_order_score(now = Time.now, max_score = nil)
    hours = ((now - updated_at.to_time)/3600).ceil
    max_score = Card.order(:rating => :desc).take.rating if max_score.nil?
    ((max_score + 1 - rating) ** 1.5).ceil * hours
  end
end
