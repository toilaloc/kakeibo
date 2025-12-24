# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  namespace :api do
    namespace :v1 do
      resources :users, only: %i[create show destroy]

      post '/signup', to: 'users#create'
      post '/magic_links/request_magic_link', to: 'magic_links#request_magic_link'
      get '/magic_links/verify', to: 'magic_links#verify', as: :magic_link
      delete '/magic_links/logout', to: 'magic_links#logout'
    end
  end
end
