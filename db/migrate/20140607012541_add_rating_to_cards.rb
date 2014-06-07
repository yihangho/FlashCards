class AddRatingToCards < ActiveRecord::Migration
  def change
    add_column :cards, :rating, :integer, :default => 0
  end
end
