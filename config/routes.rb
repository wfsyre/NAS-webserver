Rails.application.routes.draw do

  root 'sessions#new'

  resources :users, only: [:new, :create, :show]
  resources :sessions, only: [:create, :new, :destroy]
  resources :file_transfer, only: [:show]

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
