Rails.application.routes.draw do
  resources :attendances
  resources :students
  get 'home/index'
  resource :session
  resources :passwords, param: :token
  resources :signup, only: %i[new create]
  resources :students
  get 'up' => 'rails/health#show', :as => :rails_health_check
  root 'home#index'
  resources :charge
  get 'subscriptions', to: 'subscriptions#index'
  post 'charge', to: 'charge#create'
end
