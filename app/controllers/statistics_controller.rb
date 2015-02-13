class StatisticsController < ApplicationController
  def index
    @reviews       = Review.all
    @reviews_today = Review.where(%Q("#{Review.table_name}"."created_at" >= ?), Date.today)
  end
end
