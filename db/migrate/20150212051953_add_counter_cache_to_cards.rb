class AddCounterCacheToCards < ActiveRecord::Migration
  def change
    add_column :cards, :reviews_count, :integer
    add_column :cards, :thumb_up_reviews_count, :integer
    add_column :cards, :thumb_down_reviews_count, :integer
  end
end
