Rails.application.routes.draw do

  resources :users, only: [:new, :create, :show] do
    resources :manage, only: []
  end
  resources :sessions, only: [:create, :new, :destroy]
  resources :file_transfer, only: [:index, :show]

  get "/about/", to: "about#show"
  delete "/sessions", to: "sessions#destroy"
  post "/user/promote/:id", to: "users#promote"
  post "/user/demote/:id", to: "users#demote"
  post "/user/remove/:id", to: "users#remove"
  get "/user/manage?:path", to: "users#manage"
  get "/user/manage/:id", to: "users#manage_user"
  post "/user/manage/:id/changefolder/:folder", to: "users#change_folder", as: "change_folder"
  get "/user/manage", to: "users#manage", as: "manage_user"
  post "/user/manage", to: "users#change"

  match 'download', to: 'file_transfer#download', as: 'download', via: :get
  match 'download_all', to: 'file_transfer#download_all', as: 'download_all', via: :get

  post "/file_transfer/upload", to: "file_transfer#upload"

  root :to => redirect('sessions/new')

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
