ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require './test/helpers/authentication_helper'
require './test/helpers/authentication_test_helper'

def ci?
  ENV['CI'] == 'true'
end

module SignInHelper
  # This method needs updating as it references users(:one) which doesn't exist in our fixtures
  def sign_in(user_type = :admin_user)
    user = users(user_type)
    post session_url, params: { email_address: user.email_address, password: 'password' }
  end

  # Add more specific sign-in helpers for different roles
  def sign_in_as_admin
    sign_in(:admin_user)
  end

  def sign_in_as_teacher
    sign_in(:teacher_user)
  end

  def sign_in_as_student
    sign_in(:student_user)
  end
end

class ActionDispatch::IntegrationTest
  include AuthenticationTestHelper
end

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: 8)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end
