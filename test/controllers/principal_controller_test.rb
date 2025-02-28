require 'test_helper'

class PrincipalControllerTest < ActionDispatch::IntegrationTest
  test 'should get generate_code' do
    get principal_generate_code_url
    assert_response :success
  end

  test 'should get payment_plan' do
    get principal_payment_plan_url
    assert_response :success
  end
end
