class WatchlistsController < ApplicationController
  before_action :set_watchlist, only: [:show, :edit, :update, :destroy]

  before_filter :auth_user

  # GET /watchlists
  # GET /watchlists.json
  def index
    @watchlists = Watchlist.all
  end

  # GET /watchlists/1
  # GET /watchlists/1.json
  def show
    # If an old id or a numeric id was used to find the record, then
    # the request path will not match the watchlist_path, and we should do
    # a 301 redirect that uses the current friendly id.
    if request.path != watchlist_path(@watchlist)
      return redirect_to @watchlist, :status => :moved_permanently
    end

    @watchdiv = params[:watchdiv]
    if @watchdiv == 'unwatched'
      @unwatched_movies = @watchlist.movies.unwatched.paginate(:page => params[:page], :per_page => 18).order('created_at DESC')
    else
      @unwatched_movies = @watchlist.movies.unwatched.paginate(:page => 1, :per_page => 18).order('created_at DESC')
    end
    if @watchdiv == 'been_watched'
     @watched_movies = @watchlist.movies.been_watched.paginate(:page => params[:page], :per_page => 10).order('movies.date_watched DESC')
    else
     @watched_movies = @watchlist.movies.been_watched.paginate(:page => 1, :per_page => 10).order('movies.date_watched DESC')
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @unwatched_movies }
      format.js
    end
  end

  # GET /watchlists/new
  def new
    @watchlist = Watchlist.new
  end

  # GET /watchlists/1/edit
  def edit
  end

  # POST /watchlists
  # POST /watchlists.json
  def create
    @watchlist = Watchlist.new(watchlist_params)

    respond_to do |format|
      if @watchlist.save
        format.html { redirect_to @watchlist, notice: 'Watchlist was successfully created.' }
        format.json { render :show, status: :created, location: @watchlist }
      else
        format.html { render :new }
        format.json { render json: @watchlist.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /watchlists/1
  # PATCH/PUT /watchlists/1.json
  def update
    respond_to do |format|
      if @watchlist.update(watchlist_params)
        format.html { redirect_to @watchlist, notice: 'Watchlist was successfully updated.' }
        format.json { render :show, status: :ok, location: @watchlist }
      else
        format.html { render :edit }
        format.json { render json: @watchlist.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /watchlists/1
  # DELETE /watchlists/1.json
  def destroy
    @watchlist.destroy
    respond_to do |format|
      format.html { redirect_to watchlists_url, notice: 'Watchlist was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_watchlist
      @watchlist = Watchlist.friendly.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def watchlist_params
      params.require(:watchlist).permit(:list)
    end
end
