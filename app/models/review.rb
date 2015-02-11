class Review < ActiveRecord::Base
  enum status: [:thumb_up, :thumb_down]
  default_scope { order(created_at: :desc) }

  belongs_to :card
end
