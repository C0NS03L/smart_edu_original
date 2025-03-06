Rails.application.routes.draw do
  get 'principal/generate_code', to: 'principals#generate_code', as: 'generate_code_principal'
  get 'principal/payment_plan'
  get 'signup/new_principal', to: 'signup#new_principal', as: 'new_principal_signup'
  get 'principal/dashboard', to: 'principals#dashboard', as: 'principal_dashboard'
  post 'signup/create_principal', to: 'signup#create_principal', as: 'create_principal_signup'
  post 'principals/generate_staff_code', to: 'principals#generate_staff_code', as: 'generate_staff_code_principal'
  post 'principals/generate_student_code', to: 'principals#generate_student_code', as: 'generate_student_code_principal'
  get 'student_dashboard', to: 'students#dashboard', as: 'student_dashboard'
  get 'staff_dashboard', to: 'staffs#dashboard', as: 'staff_dashboard'
  resources :attendances
  resources :students
  get 'home/index'
  resource :session
  resources :passwords, param: :token
  resources :signup, only: %i[new create]

  get 'up' => 'rails/health#show', :as => :rails_health_check
  root 'home#index'
end
