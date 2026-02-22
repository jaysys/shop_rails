Rails.application.routes.draw do
  resources :products, only: %i[index show] do
    resource :like, only: %i[create destroy], controller: :product_likes
    resources :reviews, only: :create, controller: :product_reviews
  end
  resources :cart_items, only: %i[create update destroy]
  resource :cart, only: %i[show destroy]
  resources :orders, only: %i[index show]
  resources :complaints, only: %i[index new create show]
  resources :notifications, only: %i[index update] do
    patch :read_all, on: :collection
  end
  namespace :admin do
    root "dashboard#index"
    resources :products
    resources :users, only: %i[index show update destroy]
    resources :orders, only: :show
    resources :complaints, only: %i[index show update]
  end

  resource :checkout, only: :show, controller: :checkouts do
    get :success
    get :fail
    post :client_error
  end

  resource :session, only: %i[new create destroy]
  resources :users, only: %i[new create]

  get "signup", to: "users#new"
  get "login", to: "sessions#new"
  get "profile", to: "users#edit", as: :edit_profile
  patch "profile", to: "users#update"
  delete "profile", to: "users#destroy"
  delete "logout", to: "sessions#destroy"

  get "todos", to: redirect("/")
  get "up" => "rails/health#show", as: :rails_health_check
  root "products#index"
end
