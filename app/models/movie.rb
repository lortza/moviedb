class Movie < ActiveRecord::Base
  belongs_to :category
  belongs_to :watchlist
end
