class CreateTodos < ActiveRecord::Migration
  def change
    create_table :todos do |t|
      t.string :word
      t.index :word

      t.timestamps
    end
  end
end
