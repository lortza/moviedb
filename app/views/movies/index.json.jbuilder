json.array!(@movies) do |movie|
  json.extract! movie, :id, :title, :imdb_url, :watch_url, :date_watched, :location_watched, :category_id, :watchlist_id, :our_rating, :notes, :imdb_artwork, :imdb_plot_summary, :imdb_rating, :imdb_genre
  json.url movie_url(movie, format: :json)
end
