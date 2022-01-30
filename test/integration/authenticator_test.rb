require 'test_helper'

class AuthenticatorTest < ActionDispatch::IntegrationTest
  def setup
    @user = active_user
    @token = @user.to_token
  end

  # JWTのデコードデータをテストする
  test "jwt_decode" do
    payload = UserAuth::AuthToken.new(token: @token).payload
    sub = payload["sub"]
    exp = payload["exp"]
    aud = payload["aud"]

    # subjectは一致しているか
    assert_equal(@user.id, sub)

    # expirationの値はあるか
    assert exp.present?

    # tokenの有効期限は2週間か
    # assert_in_delta(期待値, 実際値, 想定値範囲) : 期待値と実際値の差は、想定値範囲内か。をテストする。
    # 実行タイミングのズレにより、2週間後の日時と完全一致しません。
    # そこでこのテストメソッドを使い、1分の誤差を許容するようにしています。
    assert_in_delta(2.week.from_now, Time.at(exp), 1.minute)

    # audienceの値は一致しているか
    assert_equal(ENV["APP_URL"], aud)
  end

  # authenticate_userメソッドをテストする
  # users_controller.rbに追加したbefore_action :authenticate_user（オーセンティケイトユーザー）メソッドが正しく機能しているかテストする
  test "authenticate_user_method" do
    key = UserAuth.token_access_key

    # @userとcurrent_userは一致しているか
    cookies[key] = @token
    get api_url("/home/users/current_user")
    assert_response 200
    assert_equal(@user, @controller.send(:current_user))

    # 無効なトークンはアクセス不可か
    invalid_token = @token + "a"
    cookies[key] = invalid_token
    get api_url("/home/users/current_user")
    assert_response 401

    # 何も返されないか
    assert @response.body.blank?

    # トークンがnilの場合も401が返ってくるか(アクセス不可か)
    cookies[key] = nil
    get api_url("/home/users/current_user")
    assert_response 401

    # トークンの有効期限はアクセス可能か
    travel_to(UserAuth.token_lifetime.from_now - 1.minute) do
      cookies[key] = @token
      get api_url("/home/users/current_user")
      assert_response 200
      assert_equal(@user, @controller.send(:current_user))
    end

    # headerトークンが優先されているか
    # リクエストヘッダーにトークンがある場合、優先されているかテストする
    cookies[key] = @token
    other_user = User.where.not(id: @user.id).first
    header_token = other_user.to_token

    get api_url("/home/users/current_user"), headers: { Authorization: "Bearer #{header_token}"}

    # Authenticatorのトークンはheaderトークンか
    assert_equal(header_token, @controller.send(:token))
  end
end
