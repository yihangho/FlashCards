class Review < ActiveRecord::Base
  enum status: [:thumb_up, :thumb_down]
  default_scope { order(created_at: :desc) }

  belongs_to :card, counter_cache: true

  # These three callbacks mimick counter_cache. Their actions should be done
  # when the reviews_count column is potentially modified.
  # TODO when Rails is updated to 4.2, make sure the behaviors of these
  # callbacks are consistent with the implementation of counter_cache.
  # For example, at least before_destroy is changed to after_destroy.
  after_create do
    card.increment!("#{status}_reviews_count") unless card.nil? || status.nil?
  end

  before_destroy do
    card.decrement!("#{status}_reviews_count") unless card.nil? || status.nil?
  end

  after_update do
    # TODO Should probably handle also the case when card is changed

    # Possible scenarios:
    # 1. something -> nil (-1)
    # 2. nil -> something (+1)
    # 3. up (down) -> down (up) (+1, -1)

    unless card.nil? || status == status_was
      if status.nil?
        card.decrement!("#{status_was}_reviews_count")
      elsif status_was.nil?
        card.increment!("#{status}_reviews_count")
      else
        card.increment!("#{status}_reviews_count")
        card.decrement!("#{status_was}_reviews_count")
      end
    end
  end
end
