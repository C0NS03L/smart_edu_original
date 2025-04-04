Rails.application.routes.draw do
  get 'principal/generate_code', to: 'principals#generate_code', as: 'generate_code_principal'
  get 'principal/payment_plan'
  resources :principals do
    collection { get :generate_report }
  end
  get 'principal/dashboard', to: 'principals#dashboard', as: 'principal_dashboard'
  post 'principals/generate_staff_code', to: 'principals#generate_staff_code', as: 'generate_staff_code_principal'
  post 'principals/generate_student_code', to: 'principals#generate_student_code', as: 'generate_student_code_principal'
  get 'principals/manage_codes', to: 'principals#manage_codes', as: 'manage_codes_principal'
  delete 'principals/delete_code/:id', to: 'principals#delete_code', as: 'delete_code_principal'
  delete 'principals/delete_used_codes', to: 'principals#delete_used_codes', as: 'delete_used_codes_principal'

  get 'principal/settings', to: 'principals#settings', as: 'principal_settings'
  patch 'principal/settings', to: 'principals#update_settings', as: 'update_principal_settings'
  get 'student_dashboard', to: 'students#dashboard', as: 'student_dashboard'
  get 'staff_dashboard', to: 'staffs#dashboard', as: 'staff_dashboard'
  get 'staff/generate_code', to: 'staffs#generate_code', as: 'staffs_generate_code'
  post 'staff/create_code', to: 'staffs#create_code', as: 'staffs_create_code'
  get 'staff/manage_codes', to: 'staffs#manage_codes', as: 'staffs_manage_codes'
  delete 'staff/delete_code/:id', to: 'staffs#delete_code', as: 'staffs_delete_code'
  delete 'staff/delete_used_codes', to: 'staffs#delete_used_codes', as: 'staffs_delete_used_codes'
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

  get 'signup/choose_role', as: 'choose_role'
  post 'set_role', to: 'signup#set_role', as: 'set_role'

  # Add payment history routes
  get 'payment_history', to: 'payment_history#index'

  root 'home#index'
  resources :charge
  get 'subscriptions', to: 'subscriptions#index'
  post 'charge', to: 'charge#create'
  get 'qr', to: 'qr#index', as: 'qr_index'
end
