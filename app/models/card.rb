class Card < ActiveRecord::Base
  validates :word, :presence => true
end
