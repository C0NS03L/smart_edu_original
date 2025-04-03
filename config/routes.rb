Rails.application.routes.draw do
  get 'principal/generate_code', to: 'principals#generate_code', as: 'generate_code_principal'
  get 'principal/payment_plan'

  get 'principal/dashboard', to: 'principals#dashboard', as: 'principal_dashboard'
  post 'principals/generate_staff_code', to: 'principals#generate_staff_code', as: 'generate_staff_code_principal'
  post 'principals/generate_student_code', to: 'principals#generate_student_code', as: 'generate_student_code_principal'
  get 'student_dashboard', to: 'students#dashboard', as: 'student_dashboard'
  get 'staff_dashboard', to: 'staffs#dashboard', as: 'staff_dashboard'
  get 'staff/generate_code', to: 'staffs#generate_code', as: 'staffs_generate_code'
  post 'staff/create_code', to: 'staffs#create_code', as: 'staffs_create_code'
  resources :attendances

  resources :attendances do
    collection { post :qr_attendance }
  end
  resources :students
  get 'home/index'
  resource :session
  resources :passwords, param: :token
  resources :signup, only: %i[new create]

  get 'up' => 'rails/health#show', :as => :rails_health_check
  get 'signup/new_principal', to: 'signup#new_principal', as: 'new_principal_signup'
  post 'signup/create_principal', to: 'signup#create_principal', as: 'create_principal_signup'
  patch 'signup/create_principal', to: 'signup#create_principal' # Add this line

  get 'signup/choose_role', as: 'choose_role'
  post 'set_role', to: 'signup#set_role', as: 'set_role'

  resources :principals, only: %i[new create]
  resource :charge, only: [:create], controller: 'charge'

  root 'home#index'
  resources :charge
  get 'subscriptions', to: 'subscriptions#index'
  post 'charge', to: 'charge#create'
  get 'qr', to: 'qr#index', as: 'qr_index'

  post 'select_plan', to: 'signup#select_plan', as: 'select_plan'
end
