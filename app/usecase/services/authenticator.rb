module Services
  module Authenticator

    # トークンからcurrent_userを検索し、存在しない場合は401を返す
    def authenticate_user
      current_user.presence || unauthorized_user
    end

    # includeするとプライベートメソッドでもコントローラーから呼び出すことができますが、
    # コントローラー内で使用するメソッドを明確にするために、アクティブメソッドとしています。
    # クッキーを削除する
    def delete_cookie
      return if cookies["token_access_key"].blank?
      cookies.delete(token_access_key)
    end

    private
      # リクエストヘッダーからトークンを取得する(主に一時的に発行したトークンを取得する際に使用)
      # 一時的に発行するトークンを使用する場面は、
      # 会員登録時のメールアドレス認証時
      # パスワードリセット時
      # メールアドレス変更時
      def token_from_request_headers
        request.headers["Authorization"]&.split&.last
      end

      # クッキーのオブジェクトキー(config/initializers/user_auth.rb)
      def token_access_key
        UserAuth.token_access_key
      end

      # トークンの取得(リクエストヘッダー優先)
      # メールアドレスの変更時は
      # リクエストヘッダーのトークンとクッキートークンの
      # 双方が存在することになるため、リクエストヘッダーを優先して取得するよう実装しています。
      def get_token
        token_from_request_headers || cookies[token_access_key]
      end

      # トークンからユーザを取得する
      def fetch_entity_from_token
        AuthTokne.new(token: token).entity_for_user
      rescue ActiveRecord::RecordNotFound, JWT::DecodeError, JWT::EncodeError
        nil
      end

      # トークンのユーザを返す
      def current_user
        return if token.blank?
        # ||= この書き方はローカルキャッシュと言い、無駄なメソッドの実行を防ぎます。
        @_current_user ||= fetch_entity_from_token
      end

      # 401エラーかつ、クッキーを削除する
      def unauthorized_user
        head(:unauthorized) && delete_cookie
      end

  end
end

# トークンの取得は2パターン
# リクエストのヘッダーから取得するパターン(主に一時的に発行したトークンを取得する際に使用)
# クッキーに保存したトークンを取得するパターンがある
