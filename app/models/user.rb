# Active Recordのモデルを継承すれば完成
# Userモデルを作成し、データベースのusersテーブルにマッピングされる。
class User < ApplicationRecord

  include Services::Tokenizable

  before_validation :downcase_email

  # gem bcrypt
  has_secure_password
  VALID_PASSWORD_REGEX = /\A[\w\-]+\z/

  # presence（プレゼンス）: true ... 入力必須を検証します。Boolean型に入力必須のバリデーションは設定しないように
  # →ようはnameがない場合は保存されない
  # allow_blank: true ... NULL、空白の場合は検証をスキップします。
  validates :name, presence: true, length: { maximum: 30, allow_blank: true }

  validates :email, presence: true, email: { allow_blank: true }

  validates :password, presence: true,
                       length: { minimum: 8 },
                       format: { with: VALID_PASSWORD_REGEX, message: :invalid_password },
                       allow_nil: true
  # Boolean型に正しくtrue、falseが入っているかを検証するにはinclusion（インクルージョン）を使用する。
  validates :activated, inclusion: { in: [ true, false ] }



  class << self
    # emailからアクティブなユーザを返す
    def find_activated(email)
      find_by(email: email, activated: true)
    end
  end

  # インスタンスメソッド 変数.メソッド名
  # 自分以外の同じemailのアクティブなユーザがいる場合にtrueを返す
  # ?は慣習でbooleanを返す意味
  def email_activated?
    users = User.where.not(id: id)
    users.find_activated(email).present?
  end

  # 共通のJSONレスポンス
  def my_json
    as_json(only: [:id, :nama, :email, :created_at)
  end

  private
    # email小文字化
    def downcase_email
      self.email.downcase! if email
    end

end

# allow_blank: trueの使い所
# 例えば「入力必須」と「文字数10文字以上」のバリデーションを設定したnameカラムを未入力で保存した場合。
# Railsは素直なので双方の検証エラーを吐き出します。
# 「名前を入力してください」
# 「名前は10文字以上で入力してください」
# エンドユーザーからすれば、エラーメッセージが大量に表示されることは非常にストレスです。
# ここで出力すべきは入力してないことによるエラー「名前を入力してください」のメッセージだけで良いのです。
# このようにallow_blank: trueは、未入力の場合に無駄な検証を行わない場合に使用します。

