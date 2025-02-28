Rails.application.routes.draw do
  get 'principal/generate_code'
  get 'principal/payment_plan'
  resources :attendances
  resources :students
  get 'home/index'
  resource :session
  resources :passwords, param: :token
  resources :signup, only: %i[new create]
  resources :students
  get 'up' => 'rails/health#show', :as => :rails_health_check
  root 'home#index'
end
