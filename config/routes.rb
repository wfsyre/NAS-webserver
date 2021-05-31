Rails.application.routes.draw do

  get 'admin/index'
  get 'admin/show'
  get 'admin/destroy'
  resources :users, only: [:new, :create, :show] do
    resources :admin, only: [:show, :index]
  end
  resources :sessions, only: [:create, :new, :destroy]
  resources :file_transfer, only: [:index, :show]
  resources :about, only: [:index]

  delete "/sessions", to: "sessions#destroy"
  post "/admin/promote/:id", to: "admin#promote"
  post "/admin/demote/:id", to: "admin#demote"
  post "/admin/remove/:id", to: "admin#remove"
  post "/admin/change_folder/", to: "admin#change_folder", as: "change_folder"
  post "/admin/index/", to: "admin#change"
  post "/admin/add_folder/", to: "admin#add_folder", as: "add_folder"

  match 'download', to: 'file_transfer#download', as: 'download', via: :get
  match 'download_all', to: 'file_transfer#download_all', as: 'download_all', via: :get

  post "/file_transfer/upload", to: "file_transfer#upload"

  root :to => redirect('sessions/new')

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
