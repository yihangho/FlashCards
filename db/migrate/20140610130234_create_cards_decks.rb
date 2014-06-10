class CreateCardsDecks < ActiveRecord::Migration
  def change
    create_table :cards_decks, :id => false do |t|
      t.belongs_to :card
      t.belongs_to :deck

      t.index [:card_id, :deck_id]
      t.index [:deck_id, :card_id]
    end
  end
end
