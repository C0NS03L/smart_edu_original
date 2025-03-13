module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    before_action :set_current_school
    helper_method :authenticated?, :current_school
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end
  end

  private

  def set_current_school
    if authenticated?
      Current.school =
        case
        when Current.session.user.present?
          Current.session.user.school
        when Current.session.principal.present?
          Current.session.principal.school
        when Current.session.staff.present?
          Current.session.staff.school
        when Current.session.student.present?
          Current.session.student.school
        end
    end
  end

  def current_school
    Current.school
  end

  def authenticated?
    resume_session.present?
  end

  def require_authentication
    resume_session || request_authentication
  end

  def resume_session
    return Current.session if Current.session

    if (session = find_session_by_cookie)
      Current.session = session

      # Set current account based on session type
      if session.user
        Current.user = session.user
      elsif session.principal
        Current.principal = session.principal
      elsif session.staff
        Current.staff = session.staff
      elsif session.student
        Current.student = session.student
      elsif session.system_admin
        Current.system_admin = session.system_admin
      end

      set_current_school
      session
    end
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

    # Set the appropriate Current variable based on account type
    case account
    when User
      Current.user = account
    when Principal
      Current.principal = account
    when Staff
      Current.staff = account
    when Student
      Current.student = account
    when SystemAdmin
      Current.system_admin = account
    end

    # Set current school based on account type
    set_current_school

    cookies.signed.permanent[:session_id] = { value: session.id, httponly: true, same_site: :lax }
  end

  def terminate_session
    Current.session&.destroy
    Current.reset
    cookies.delete(:session_id)
  end
end
