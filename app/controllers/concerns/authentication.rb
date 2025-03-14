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
    Current.school = Current.user.school if authenticated? && Current.user.present?
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
      Current.user = session.user if session.user
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
    case Current.user&.type
    when 'Principal'
      principal_dashboard_path
    when 'Staff'
      staff_dashboard_path
    when 'Student'
      student_dashboard_path
    when 'SystemAdmin'
      admin_dashboard_path
    else
      root_url
    end
  end

  def start_new_session_for(user)
    # Create the session directly with only the required attributes
    session = Session.new(user_agent: request.user_agent, ip_address: request.remote_ip)

    # Explicitly set the user association to avoid automatic setting of type-specific columns
    session.user = user
    session.save!

    Current.session = session
    Current.user = user

    # Set current school
    set_current_school

    cookies.signed.permanent[:session_id] = { value: session.id, httponly: true, same_site: :lax }
  end

  def terminate_session
    Current.session&.destroy
    Current.reset
    cookies.delete(:session_id)
  end
end
