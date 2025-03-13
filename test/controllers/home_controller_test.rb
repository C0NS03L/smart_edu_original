require 'test_helper'

class HomeControllerTest < ActionDispatch::IntegrationTest
  # test 'should get index when logged in as student' do
  #   sign_in_as_student
  #   get root_path
  #   assert_response :success
  #   assert_includes @response.body, 'Student Details'
  #   assert_includes @response.body, 'School Details'
  #   assert_includes @response.body, 'QR Code'
  #   assert_includes @response.body, 'Attendance History'
  # end

  # test 'should get index when logged in as staff' do
  #   sign_in_as_staff
  #   get root_path
  #   assert_response :success
  #   assert_includes @response.body, 'Classes'
  #   assert_includes @response.body, 'Total Check Ins'
  # end

  test 'not logged in should get redirected to login' do
    get root_path
    assert_redirected_to new_session_path
  end

  private

  def sign_in_as_student
    user = users(:student)
    post session_url, params: { email_address: user.email_address, password: 'password' }
  end

  def sign_in_as_staff
    user = users(:staff)
    post session_url, params: { email_address: user.email_address, password: 'password' }
  end
end
