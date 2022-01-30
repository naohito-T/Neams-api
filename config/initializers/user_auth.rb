module UserAuth
  # JWT有効期限のデフォルト値
  mattr_accessor :token_lifetime # getとsetter
  self.token_lifetime = 2.week # 2週間
  # 受信者を識別する文字列を指定する。
  # audienceの値は、受信者（トークンが送られる保護対象リソースのURL）
  # 今回のjwtの受信者はRailsとなる。
  mattr_accessor :token_audience
  self.token_audience = -> { ENV["APP_URL"] }

  mattr_accessor :token_signature_algorithm
  self.token_signature_algorithm = "HS256"

  # 署名に使用する鍵を指定。Railsのシークレットキーを使用します。この秘密鍵で署名と検証を行います。
  mattr_accessor :token_secret_signature_key
  self.token_secret_signature_key = -> {
    Rails.application.credentials.secret_key_base
  }
  # 公開鍵を使用する場合はここに指定。署名アルゴリズムがHS256の場合は使用しません。
  mattr_accessor :token_public_key
  self.token_public_key = nil

  # Cookieに保存する際のオブジェクトキーを指定。CookieからJWTを取得する場合は、cookies[:access_token]となる。
  mattr_accessor :token_access_key
  self.token_access_key = :access_token

  mattr_accessor :not_found_exception_class
  self.not_found_exception_class = ActiveRecord::RecordNotFound
end

# mattr_accessor（モジュールアクセサ）
# Rubyのattr_accessor（アトリビューアクセサ）を拡張した、Railsのモジュール用アクセサメソッド
# ここで宣言したアクセサは、<モジュール名>.<アクセサ名>でアクセスすることができます。
