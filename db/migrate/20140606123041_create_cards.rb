class CreateCards < ActiveRecord::Migration
  def change
    create_table :cards do |t|
      t.string :word
      t.string :type
      t.string :definition
      t.string :synonyms
      t.string :antonyms
      t.string :sentence

      t.index :word

      t.timestamps
    end
  end
end
