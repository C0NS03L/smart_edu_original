class SignupController < ApplicationController
  allow_unauthenticated_access only: %i[new create set_role choose_role new_principal create_principal] 

  def new
    @role = params[:role] || ""
    @user = User.new
  end

  def create
    @role = params[:role] || ""
    puts "Role: #{@role}"
    @user = User.new(user_params)
    if @user.save
      start_new_session_for @user
      redirect_to after_authentication_url
    else
      render :new, status: :unprocessable_entity
    end
  end

  def choose_role
  end

  def set_role
    role = params[:role]
    #TODO: Check if role is valid
    # redirect based on role, use switch case to redirect to different paths
    case role
    when "student"
      redirect_to new_signup_path(role: role)
    when "principal"
      redirect_to new_principal_signup_path(role: role)
    else
      redirect_to choose_role_path, notice: "Invalid role"
    end
  end 

  def new_principal
    @principal = Principal.new
  end

  def create_principal
    @principal = Principal.new(principal_params)
    if @principal.save
      # start_new_session_for @principal
      redirect_to after_authentication_url
    else
      render :new_principal
    end
  end

  private

  def user_params
    params.require(:user).permit(:email_address, :password, :password_confirmation, :enrollment_code)
  end

  def principal_params
    params.require(:principal).permit(:school_id, :name, :email_address, :phone_number, :password, 
:password_confirmation)
  end
end