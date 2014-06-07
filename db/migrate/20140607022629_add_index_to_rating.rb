class AddIndexToRating < ActiveRecord::Migration
  def change
    add_index :cards, :rating
  end
end
