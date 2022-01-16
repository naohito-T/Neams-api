class EmailValidator < ActiveModel::EachValidator
  # カスタムバリデーション用
  def validate_each(record, attribute, value)
    # debug
    # binding.pry
    max = 255
    # errorにattribute : email , countで文字数
    record.errors.add(attribute, :too_long, count: max) if value.length > max

    format = /\A\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*\z/
    # =~ 文字列と正規表現が一致するかを判定する
    record.errors.add(attribute, :invalid) unless format =~ value
    # メールアドレスの認証済みユーザがいないか確認する。
    record.errors.add(attribute, :taken) if record.email_activated?
  end
end
