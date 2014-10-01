class Todo < ActiveRecord::Base
  validates :word, :presence => true
end
