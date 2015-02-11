class CreateReviews < ActiveRecord::Migration
  def change
    create_table :reviews do |t|
      t.references :card,   null: false
      t.integer    :status, null: false

      t.index [:card_id, :status]

      t.timestamps
    end
  end
end
