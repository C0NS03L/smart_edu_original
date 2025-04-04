module AuthenticationTestHelper
  # Signs in a user by directly setting up the session
  def sign_in_as(user)
    # Create an actual session record
    session_record = Session.create!(user: user, ip_address: '127.0.0.1', user_agent: 'Rails Test')

    # For integration tests, we need to use the plain cookies hash
    cookies[:session_id] = session_record.id.to_s

    # Monkey patch the find_session_by_cookie method for the test environment
    ApplicationController.class_eval do
      define_method(:find_session_by_cookie) { Session.find_by(id: cookies[:session_id]) if cookies[:session_id] }
    end

    # Set Current object for controller access
    Current.user = user
    Current.session = session_record
    Current.school = user.school

    session_record
  end

  # Signs out the current user
  def sign_out
    cookies.delete(:session_id)
    Current.reset
  end
end
