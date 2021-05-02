Rails.application.routes.draw do

  root 'sessions#new'

  resources :users, only: [:new, :create, :index, :show]
  resources :sessions, only: [:new, :create, :destroy]

  get '/login', to: 'sessions#login'
  get '/login', to: 'sessions#create'
  get '/logout', to: 'sessions#destroy'
  get '/logout', to: 'sessions#destroy'

  get 'file_transfer/show'

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
