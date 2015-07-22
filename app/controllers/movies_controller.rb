class MoviesController < ApplicationController
  before_action :set_movie, only: [:show, :edit, :update, :destroy]

  before_filter :auth_user

  # GET /movies
  # GET /movies.json
  def index
    if params[:search]
     @movies = Movie.where("title LIKE '%#{params[:search]}%'")
     if @movies.length.zero?
       flash[:notice] = 'Sorry, there are no matching titles for your search.'
       @unwatched_movies = Movie.unwatched.paginate(:page => params[:page], :per_page => 12).order('created_at DESC')
       @watched_movies = Movie.been_watched.paginate(:page => params[:page], :per_page => 12).order('created_at DESC')
     end
   else
     @watchdiv = params[:watchdiv]
     if @watchdiv == 'unwatched'
      @unwatched_movies = Movie.unwatched.paginate(:page => params[:page], :per_page => 2).order('created_at DESC')
      @unwatched_pager = params[:page].to_i
      puts "unwatched page number is #{@unwatched_pager.inspect}"
      puts "watched page number is #{@watched_pager.inspect}"
    else
      @unwatched_movies = Movie.unwatched.paginate(:page => @unwatched_pager, :per_page => 2).order('created_at DESC')
    end
    if @watchdiv == 'been_watched'
     @watched_movies = Movie.been_watched.paginate(:page => params[:page], :per_page => 2).order('created_at DESC')
     @watched_pager = params[:page].to_i
     puts "unwatched page number is #{@unwatched_pager.inspect}"
     puts "watched page number is #{@watched_pager.inspect}"
    else
     @watched_movies = Movie.been_watched.paginate(:page => @watched_pager, :per_page => 2).order('created_at DESC')
    end
   end
   respond_to do |format|
    format.html # index.html.erb
    format.json { render json: @unwatched_movies }
    format.js
  end
 end


  # GET /movies/1
  # GET /movies/1.json
  def show
  end

  # GET /movies/new
  def new
    @movie = Movie.new
  end

  # GET /movies/1/edit
  def edit
  end

  # POST /movies
  # POST /movies.json
  def create
    # check if we want to bypass the API
    if movie_params[:bypassapi] == "Bypass API"
      @movie_info = movie_params

    else
      # use the API and get the movie title via form
      @movie_title = movie_params[:title].gsub(" ","-")

      # get data from the api based on movie title
      @content = open("http://www.omdbapi.com/?t=#{@movie_title}&y=&plot=short&r=json").read

      # parse the results to a ruby hash
      @results = JSON.parse(@content, symbolize_names: true)

      # check if API has an error. if so, use movie_params
      if @results[:Error] == "Movie not found!"
        @movie_info = movie_params

      else
        # parse the date
        @parsed_date = Date.new(movie_params["date_watched(1i)"].to_i,
          movie_params["date_watched(2i)"].to_i, movie_params["date_watched(3i)"].to_i) unless ! movie_params["date_watched(1i)"].present?

        # create the hash for the movie params
        @movie_info = { title: @results[:Title],
          imdb_url: "http://www.imdb.com/title/#{@results[:imdbID]}/",
          watch_url: movie_params[:watch_url],
          date_watched: @parsed_date,
          location_watched: movie_params[:location_watched],
          category_id: movie_params[:category_id],
          watchlist_id: movie_params[:watchlist_id],
          our_rating: movie_params[:our_rating],
          preview_link: movie_params[:preview_link],
          been_watched: movie_params[:been_watched],
          notes: movie_params[:notes],
          imdb_artwork: @results[:Poster].gsub("N/A", ""),
          imdb_plot_summary: @results[:Plot],
          imdb_rating: @results[:imdbRating],
          imdb_genre: @results[:Genre],
          runtime: @results[:Runtime],
          year_released: @results[:Year]}
      end #end of if/else based on API error
    end #end of if/else on whether or not to bypass the API

    # assign hash to a new movie object
    @movie = Movie.new(@movie_info)

    # save new movie object to the database
    respond_to do |format|
      if @movie.save!
        format.html { redirect_to movies_url, notice: 'Movie was successfully created.' }
        format.json { render :show, status: :created, location: @movie }
      else
        format.html { render :new }
        format.json { render json: @movie.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /movies/1
  # PATCH/PUT /movies/1.json
  def update
    respond_to do |format|
      if @movie.update(movie_params)
        format.html { redirect_to movies_url, notice: 'Movie was successfully updated.' }
        format.json { render :show, status: :ok, location: @movie }
      else
        format.html { render :edit }
        format.json { render json: @movie.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /movies/1
  # DELETE /movies/1.json
  def destroy
    @movie.destroy
    respond_to do |format|
      format.html { redirect_to movies_url, notice: 'Movie was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_movie
      @movie = Movie.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def movie_params
      params.require(:movie).permit(:title, :imdb_url, :watch_url, :date_watched, :location_watched,
        :category_id, :watchlist_id, :our_rating, :notes, :imdb_artwork, :imdb_plot_summary,
        :imdb_rating, :imdb_genre, :preview_link, :runtime, :been_watched, :year_released, :bypassapi)
    end
end
