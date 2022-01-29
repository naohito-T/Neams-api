require 'jwt'

# 呼び出し
# token = UserAuth::AuthToken.new.token
module Services
  class AuthToken
    # 読み取り専用
    attr_reader :token
    attr_reader :payload
    attr_reader :lifetime

    # initialize インスタンス生成時には4つの引数をもつ
    def initialize(lifetime: nil, payload: {}, token: nil, options: {})
      if token.present?
        # JWT.decode return [{payload}, {header}]
        # Rubyでは_も変数として扱うため_にはheaderが入る
        @payload, _ = JWT.decode(token.to_s, decode_key, true, decode_options.merge(options))
        @token = token
      else
        @lifetime = lifetime || UserAuth.token_lifetime
        @payload = claims.merge(payload)
        @token = JWT.encode(@payload, secret_key, algorithm, header_fields)
      end
    end

    # payloadのsubクレームからユーザーを検索します。
    def entity_for_user
      User.find @payload["sub"]
    end

    # token_lifetimeの日本語変換を返す
    # inspect : オブジェクトを人間が読める形式に変換する 2.hours → "2 hours"
    #
    def lifetime_text
      time, period = @lifetime.inspect.sub(/s\z/, "").split
      time + I18n.t("datetime.periods.#{period}", default: "")
    end

    private
      # エンコードキー
      def secret_key
        UserAuth.token_secret_signature_key.call
      end
      # デコードキー
      def decode_key
        # UserAuth.token_public_key.call || secret_key
        secret_key
      end
      # アルゴリズム(config/initializers/user_auth.rb)
      def algorithm
        UserAuth.token_signature_algorithm
      end
      # オーディエンスの値がある場合にtrueを返す
      def verify_audience?
        UserAuth.token_audience.present?
      end
      # オーディエンス(config/initializers/user_auth.rb)
      def token_audience
        verify_audience? && UserAuth.token_audience.call # verify_audienceがtrueにならそのまま返す
      end
      # トークン有効期限を秒数で返す
      def token_lifetime
        @lifetime.from_now.to_i
      end
      # デコード時オプション
      # default: https://www.rubydoc.info/github/jwt/ruby-jwt/master/JWT/DefaultOptions
      def decode_options
        {
          aud: token_audience,
          verify_aud: verify_audience?,
          algorithm: algorithm
        }
      end
      # デフォルトクレーム
      # _claims ... アンダーバーから始まる変数は、ローカル変数であることを明示的にする書き方です。
      def claims
        _claims = {}
        _claims[:exp] = token_lifetime
        _claims[:aud] = token_audience if verify_audience?
        _claims
      end
      # エンコード時のヘッダー
      # Doc: https://openid-foundation-japan.github.io/draft-ietf-oauth-json-web-token-11.ja.html#typHdrDef
      def header_fields
        { typ: "JWT" }
      end
  end
end
