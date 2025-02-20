Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
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
