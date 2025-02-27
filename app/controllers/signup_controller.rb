class SignupController < ApplicationController
  allow_unauthenticated_access only: %i[new create new_principal create_principal]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to root_path, notice: 'User was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def new_principal
    @principal = Principal.new
  end

  def create_principal
    @principal = Principal.new(principal_params)
    if @principal.save
      redirect_to root_path, notice: 'Principal was successfully created.'
    else
      render :new_principal
    end
  end

  private

  def user_params
    params.require(:user).permit(:email_address, :password, :password_confirmation, :enrollment_code)
  end

  def principal_params
    params.require(:principal).permit(:name, :email, :phone_number, :password, :enrollment_code)
  end
end