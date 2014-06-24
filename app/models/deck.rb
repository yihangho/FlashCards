class Deck < ActiveRecord::Base
  validates :title, :presence => true
  validates :title, :uniqueness => true
  has_and_belongs_to_many :cards

  def self.find_or_create(*args)
    args.map do |title|
      deck = Deck.find_by(:title => title)
      if deck
        deck
      else
        deck = Deck.create(:title => title)
        if deck.save
          deck
        else
          nil
        end
      end
    end.delete_if { |deck| deck.nil? }
  end
end
