Rails.application.routes.draw do

  root 'sessions#new'

  resources :users, only: [:new, :create, :show]
  resources :sessions, only: [:create, :new, :destroy]
  resources :file_transfer, only: [:show]

  get "/about/", to: "about#show"
  delete "/sessions", to: "sessions#destroy"
  post "/user/promote/:id", to: "users#promote"
  post "/user/demote/:id", to: "users#demote"
  post "/user/remove/:id", to: "users#remove"
  get "/user/manage?:path", to: "users#manage"
  get "/user/manage/:id", to: "users#manage_user"
  get "/user/manage", to: "users#manage"
  post "user/manage", to: "users#change"

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
