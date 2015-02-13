class StatisticsController < ApplicationController
  def index
    @reviews       = Review.all
    @reviews_today = Review.where(%Q("#{Review.table_name}"."created_at" >= ?), Date.today)
  end

  def card
    card = Card.find(params[:id])

    respond_to do |format|
      format.json do
        render json: {
          word: card.word,
          created_at: card.created_at,
          last_revised_at: card.reviews.pluck(:created_at).first,
          thumbs_up_reviews: card.reviews.thumb_up.pluck(:created_at),
          thumbs_down_reviews: card.reviews.thumb_down.pluck(:created_at)
        }
      end
    end
  end
end
