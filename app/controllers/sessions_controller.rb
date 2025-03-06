class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[new create]
  rate_limit to: 10,
             within: 3.minutes,
             only: :create,
             with: -> { redirect_to new_session_url, alert: 'Try again later.' }

  def new
  end

  def create
    account = find_account_by_email(params[:email_address])
    if account&.authenticate(params[:password])
      start_new_session_for(account)
      redirect_to after_authentication_url
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
    [User, Principal, Staff, SystemAdmin].each do |account_type|
      account = account_type.find_by(email_address: email)
      return account if account
    end
    nil
  end

  def after_authentication_url
    if Current.session.principal
      principal_dashboard_path
    elsif Current.session.staff
      staff_dashboard_path # Assuming this path helper exists
    elsif Current.session.student
      student_dashboard_path # Assuming this path helper exists
    else
      root_path # Fallback to root path if none of the above
    end
  end
end
