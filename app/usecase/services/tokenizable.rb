# このモジュールは、トークンの発行と発行主の検索を行います。

module Services
  module Tokenizable
    # UserクラスからToknizableモジュールのメソッドを呼び出せるようにself.included
    # self.included クラスにモジュールが含まれている場合、このメソッドが実行される
    # UserクラスでTokenizableをインクルードした時にbase.extend classMethodsが実行される
    def self.included(base)
      base.extend ClassMethods
    end
    # baseはincludeしたクラスが入る

    ## class method
    module ClassMethods
      def from_token(token)
        # トークンをデコードしたpayloadのユーザID(sub)からユーザを検索し返す
        auth_token = AuthToken.new(token: token)
        from_token_payload(auth_token.payload)
      end

      private
        def from_token_payload(payload)
          find(payload["sub"])
        end
    end

    ## インスタンスメソッド
    def to_token
      AuthToken.new(payload: to_token_payload).token
    end

    # 会員登録時のメール認証やパスワードリセットなどはセキュリティを考慮してトークンの有効期限を短めに設定する必要
    # その際に使用する
    def to_lifetime_token(lifetime)
      auth = AuthToken.new(lifetime: lifetime, payload: to_token_payload)
      { token: auth.token, lifetime_text: auth.lifetime_text }
    end

    private
      def to_token_payload
        { sub: id }
      end
  end
end
