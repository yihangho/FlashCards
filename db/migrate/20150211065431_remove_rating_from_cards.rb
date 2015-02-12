class RemoveRatingFromCards < ActiveRecord::Migration
  def change
    remove_column :cards, :rating, :integer
  end
end
