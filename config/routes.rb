Rails.application.routes.draw do
  get 'principal/generate_code'
  get 'principal/payment_plan'

  resources :attendances do
    collection { post :qr_attendance }
  end

  resources :students
  get 'home/index'
  resource :session
  resources :passwords, param: :token
  resources :signup, only: %i[new create]

  get 'signup/new_principal', to: 'signup#new_principal', as: 'new_principal_signup'
  post 'signup/create_principal', to: 'signup#create_principal', as: 'create_principal_signup'

  get 'signup/choose_role', as: 'choose_role'
  post 'set_role', to: 'signup#set_role', as: 'set_role'

  get 'up' => 'rails/health#show', :as => 'rails_health_check'
  root 'home#index'
  get 'qr', to: 'qr#index'
end
