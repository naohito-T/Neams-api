require 'test_helper'

class Api::V1::Home::UserTokenControllerTest < ActionDispatch::IntegrationTest

  def user_token_logged_in(user)
    params = { auth: { email: user.email, password: "password" } }
    post api_url("/user_token"), params: params
    assert_response 200
  end

  def setup
    @user = active_user
    @key = UserAuth.token_access_key
    user_token_logged_in(@user)
  end

  test "create_action" do
    # アクセストークンはCookieに保存されているか
    cookie_token = @request.cookie_jar[@key]
    assert cookie_token.present?

    # Cookieオプションの取得
    cookie_options = @request.cookie_jar.instance_variable_get(:@set_cookies)[@key.to_s]

    # Cookieのオプションをテストする
    # テスト項目
    # expires(エクスパイアーズ)の値は正しいか
    # secure(セキュア)は開発環境でfalseか
    # http_onlyはtrueであるか
    exp = UserAuth::AuthToken.new(token: cookie_token).payload["exp"]
    assert_equal(Time.at(exp), cookie_options[:expires])

    assert_equal(Rails.env.production?, cookie_options[:secure])

    assert cookie_options[:http_only]

    # レスポンス有効期限は一致しているか
    assert_equal exp, response_body["exp"]

    # レスポンスユーザーは一致しているか
    assert_equal @user.my_json, response_body["user"]
  end

  # destory test
  test "destroy_action" do
    assert @request.cookie_jar[@key].present?

    delete api_url("/user_token")
    assert_response 200

    # Cookieは削除されているか
    assert @request.cookie_jar[@key].nil?
  end

end
