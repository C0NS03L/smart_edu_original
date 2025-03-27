require 'test_helper'

class PrincipalControllerTest < ActionDispatch::IntegrationTest
  setup do
    @principal = users(:principal_user)
    @student = users(:student_user)
    sign_in_as(@principal)
  end

  test 'should get dashboard for principal' do
    get principal_dashboard_path
    assert_response :success
  end

  test 'should get generate_code' do
    get generate_code_principal_path
    assert_response :success
  end

  test 'should create staff enrollment code' do
    assert_difference('EnrollmentCode.count') do
      # Change to use usage_limit parameter directly as expected by controller
      post generate_staff_code_principal_path, params: { usage_limit: 5 }
    end
    # Fix the redirect expectation to match the controller
    assert_redirected_to generate_code_principal_path
    # Fix the flash notice expectation to match the controller
    assert_match /Staff Code Generated:/, flash[:notice]
  end

  test 'should create student enrollment code' do
    assert_difference('EnrollmentCode.count') do
      # Change to use usage_limit parameter directly
      post generate_student_code_principal_path, params: { usage_limit: 5 }
    end
    # Fix the redirect expectation
    assert_redirected_to generate_code_principal_path
    # Fix the flash notice expectation
    assert_match /Student Code Generated:/, flash[:notice]
  end

  test 'should not create staff enrollment code with invalid usage limit' do
    assert_no_difference('EnrollmentCode.count') { post generate_staff_code_principal_path, params: { usage_limit: 0 } }
    assert_equal 'Invalid number of accounts required.', flash[:alert]
    assert_redirected_to generate_code_principal_path
  end

  test 'should not create student enrollment code with invalid usage limit' do
    assert_no_difference('EnrollmentCode.count') do
      post generate_student_code_principal_path, params: { usage_limit: 0 }
    end
    assert_equal 'Invalid number of accounts required.', flash[:alert]
    assert_redirected_to generate_code_principal_path
  end

  test 'should deny access to non-principals' do
    sign_in_as(@student)
    get principal_dashboard_path
    # You might need to adjust this based on your actual authorization logic
    assert_redirected_to root_path
  end
end
