require 'test_helper'

class HomeControllerTest < ActionDispatch::IntegrationTest
  setup do
    @principal = users(:principal_user)
    @student = users(:student_user)
    @staff = users(:staff_user)
  end

  test 'should redirect principal to principal dashboard' do
    sign_in_as(@principal)
    get root_url
    assert_redirected_to principal_dashboard_path
  end

  test 'should redirect student to student dashboard' do
    sign_in_as(@student)
    get root_url
    assert_redirected_to student_dashboard_path
  end

  test 'should redirect staff to staff dashboard' do
    sign_in_as(@staff)
    get root_url
    assert_redirected_to staff_dashboard_path
  end
end
