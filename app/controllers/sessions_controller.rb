class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[new create]
  skip_before_action :authorize_principal!, raise: false
  skip_before_action :authorize_staff!, raise: false
  skip_before_action :authorize_student!, raise: false
  rate_limit to: 10,
             within: 3.minutes,
             only: :create,
             with: -> { redirect_to new_session_url, alert: 'Try again later.' }

  def new
  end

  def create
    user = User.find_by(email_address: params[:email_address])
    if user&.authenticate(params[:password])
      start_new_session_for(user)

      # Check if there's a pending payment to resume
      if session[:pending_payment].present?
        payment_params = session.delete(:pending_payment)

        redirect_to charge_path(
                      amount: payment_params[:amount],
                      tier: payment_params[:tier],
                      omiseToken: payment_params[:omise_token],
                      omiseSource: payment_params[:omise_source]
                    )
      else
        redirect_to after_authentication_url
      end
    else
      flash[:alert] = 'Invalid email or password'
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    terminate_session
    redirect_to root_url
  end

  private

  def find_account_by_email(email)
    # With STI, we only need to check the User model as all types inherit from it
    User.find_by(email_address: email)
  end

  def after_authentication_url
    # Now we determine the path based on the user's type
    case Current.user.type
    when 'Principal'
      principal_dashboard_path
    when 'Staff'
      staff_dashboard_path
    when 'Student'
      student_dashboard_path
    when 'SystemAdmin'
      admin_dashboard_path # Adjust if needed
    else
      root_path
    end
  end
end
