class AddTitleIndexToDecks < ActiveRecord::Migration
  def change
    add_index :decks, :title, :unique => true
  end
end
