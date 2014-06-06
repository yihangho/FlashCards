class SetDefaultValueForCards < ActiveRecord::Migration
  def change
    [:word_type, :definition, :synonyms, :antonyms, :sentence].each do |sym|
      change_column :cards, sym, :string, :default => ""
    end
  end
end
