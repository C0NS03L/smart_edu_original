module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    helper_method :authenticated?
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end
  end

  private

  def authenticated?
    resume_session
  end

  def require_authentication
    resume_session || request_authentication
  end

  def resume_session
    Current.session ||= find_session_by_cookie
  end

  def find_session_by_cookie
    Session.find_by(id: cookies.signed[:session_id]) if cookies.signed[:session_id]
  end

  def request_authentication
    session[:return_to_after_authenticating] = request.url
    redirect_to new_session_path
  end

  def after_authentication_url
    if Current.session.user
      user_dashboard_path
    elsif Current.session.principal
      principal_dashboard_path
    elsif Current.session.staff
      staff_dashboard_path
    elsif Current.session.student
      student_dashboard_path
    elsif Current.session.system_admin
      admin_dashboard_path
    else
      root_url
    end
  end

  def start_new_session_for(account)
    session =
      case account
      when User
        account.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip)
      when Principal
        account.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip, principal: account)
      when Staff
        account.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip, staff: account)
      when Student
        account.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip, student: account)
      when SystemAdmin
        account.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip, system_admin: account)
      end
    Current.session = session
    cookies.signed.permanent[:session_id] = { value: session.id, httponly: true, same_site: :lax }
  end

  def terminate_session
    Current.session.destroy
    cookies.delete(:session_id)
    cookies.delete(:account_type)
  end
end
