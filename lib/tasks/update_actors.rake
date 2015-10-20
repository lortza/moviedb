task :update_actors => :environment do
  Movie.connection
  @movies = Movie.all
  @movies.each do |movie|
    if movie.imdb_actors == nil
      content = open("http://www.omdbapi.com/?t=#{movie.title}&y=&plot=short&r=json").read
      results = JSON.parse(content, symbolize_names: true)
      movie.imdb_actors =  results[:Actors]
      movie.save
    end
  end
end