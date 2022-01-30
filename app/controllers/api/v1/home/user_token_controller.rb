# ログインコントローラーの責務
# フロントからきたログイン情報を受取り
# userを検索
# userが存在した場合はトークンを発行し、Cookieに保存する
# フロントには有効期限のみを返す

class Api::V1::Home::UserTokenController < ApplicationController

  # resucue_from エラークラス, with: :メソッド名
  # 引数のエラーが発生した際に処理をメソッドに委任する
  rescue_from UserAuth.not_found_exception_class, with: :not_found

  # Authenticatorモジュールのdelete_cookieメソッドが実行され、Cookieが削除されます。
  before_action :delete_cookie
  before_action :authenticate, only: [:create]

  # login
  def create
    cookies[token_access_key] = cookie_token
    render json: { exp: auth.payload[:exp], user: entity.my_json}
  end

  # logout Cookieを削除するだけ
  def destroy
    head(:ok)
  end

  private
    def entity
      @_entity ||= User.find_activated(auth_params[:email])
    end

    def auth_params
      params.require(:auth).permit(:email, :password)
    end

    # トークンを発行する
    def auth
      @_auth ||= UserAuth::AuthToken.new(payload: { sub: entity.id })
    end

    # NotFoundエラー発生時にヘッダーレスポンスのみを返す
    # Rails側のRecordNotFoundエラーが発生した場合、フロントはユーザーが存在しません。と
    # トースタを表示するだけでいい。Railsが吐き出すエラーの内容は必要ない
    # 以下でヘッダーレスポンスのみを返すメソッドに週略ｓるう
    def not_found
      head(:not_found)
    end

    # Cookieに保存する
    def cookie_token
      {
        # Cookieの値
        value: auth.token,
        # Cookieの有効期限(設定しないとブラウザを閉じた際にCookieは削除される)
        expires:  Time.at(auth.payload[:exp]),
        # https通信でしかアクセスできないCookieとなる(本番環境のみ有効)
        secure: Rails.env.production?,
        # JavaScriptからアクセスできないCookieとなる
        http_only: true
       }
    end

    # entityが存在しない、entityのパスワードが一致しない場合に404を出す
    def authenticate
      unless entity.present? && entity.authenticate(auth_params[:password])
        raise UserAuth.not_found_exception_class
      end
    end

end
