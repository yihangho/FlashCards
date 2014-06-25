class Todo < ActiveRecord::Base
  validates :word, :presence => true

  def self.delete_if_exists(word)
    todo = find_by(:word => word)
    todo.delete if todo
  end
end
