require 'test_helper'

class ReviewControllerTest < ActionDispatch::IntegrationTest
  test 'should get get' do
    get review_get_url
    assert_response :success
  end
end
