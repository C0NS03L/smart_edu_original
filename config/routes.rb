Rails.application.routes.draw do
  resources :attendances
  resources :students
  get 'home/index'
  resource :session
  resources :passwords, param: :token
  resources :signup, only: %i[new create]
  resources :students

  get 'signup/new_principal', to: 'signup#new_principal', as: 'new_principal_signup'
  post 'signup/create_principal', to: 'signup#create_principal', as: 'create_principal_signup'

  get 'up' => 'rails/health#show', as: :rails_health_check
  root 'home#index'
end
