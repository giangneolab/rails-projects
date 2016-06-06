Rails.application.routes.draw do

  devise_for :users, controllers: { sessions: "users/sessions" }

  root 'restaurants#index'

  get 'restaurants/:id', to: 'restaurants#show', as: :restaurant

  get 'articles/:id' => 'articles#show', as: :article

  namespace :admin do
    resources :articles
    resources :banners
    resources :categories
    resources :restaurants
  end

  scope :admin do
    root 'admin#dashboard', as: :admin_root
  end
end
