require 'test_helper'

class Api::V1::Home::UsersControllerTest < ActionDispatch::IntegrationTest

  def setup
    @uesr = active_user
    logged_in(@user)
  end

  test "show_action" do
    get api_url("/home/users/current_user")
    assert_response 200
    assert_equal(@user.my_json, response.body)
  end

end
