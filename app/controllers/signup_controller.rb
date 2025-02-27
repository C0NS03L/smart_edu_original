class SignupController < ApplicationController
  allow_unauthenticated_access only: %i[new create]

  def new
    @user = User.new
    @schools = School.order(:name)
  end

  def create
    @user = User.new(user_params)
    if @user.save
      start_new_session_for @user
      redirect_to after_authentication_url
    else
      @schools = School.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email_address, :password, :password_confirmation, :school_id)
  end
end
