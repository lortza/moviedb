Rails.application.routes.draw do
  devise_for :users
  resources :movies
  resources :categories
  resources :watchlists

  get "nocansee", to: "static_pages#nocansee"
  get "search", to: "static_pages#index"
  get "apisearch", to: "static_pages#apisearch"

  #root 'movies#index'
  root :to => 'watchlists#show', :id => '3'

end
