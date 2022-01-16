#
# @desc modelを作成した時に自動でできるファイル
#

# test_helpter.rbに記述したメソッドはテスト内のどこからでも呼び出せる。
require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # @インスタンス変数
  def setup
    @user = active_user
  end

  # @desc name test
  test "name_validation" do
    # 入力必須
    # 最大30文字まで
    user = User.new(email: "test@example.com", password: "password")
    user.save
    required_msg = %w(名前を入力してください)
    # Railsのテストメソッド 第一引数 第二引数 が一致の場合true
    assert_equal(required_msg, user.errors.full_messages)

    # 30文字制限をテスト
    # 内容: 31文字の名前を用意し保存して見た場合、エラーメッセージは正しく出力できているかを確認
    max = 30
    name = "a" * (max + 1)
    user.name = name
    user.save
    maxlength_msg = %w(名前は30文字以内で入力してください)
    assert_equal(maxlength_msg, user.errors.full_messages)

    # 30文字が保存できるかテスト
    name = "あ" * max
    user.name = name
    # ブロック内の処理を実行した結果、第一引数が第二引数の数だけ変化していればテストが通ります。
    assert_difference("User.count", 1) do
      user.save
    end
  end

  # @desc email test
  test "email_validation" do
    # emailの入力必須をテスト
    user = User.new(name: "test", password: "password")
    user.save
    required_msg = %w(メールアドレスを入力してください)
    # エラーメッセージが同等であればtrue
    assert_equal(required_msg, user.errors.full_messages)

    # 255文字以上は保存できないかテスト
    max = 255
    domain = "@example"
    email = "a" * ((max + 1) - domain.length) + domain # 256
    assert max < email.length

    user.email = email
    user.save
    # maxlength_msg = %w(メールアドレスは255文字以内で入力してください)
    maxlength_msg = %w(メールアドレスは不正な値です)
    assert_equal(maxlength_msg, user.errors.full_messages)

    # 正しい書式で保存ができているか確認
    possible_email = %w(A@EX.COM, a-_@e-x.c-o_m.j_p, a.a@ex.com, a@e.co.js, 1.1@ex.com, a.a+a@ex.com)
    possible_email.each do |email|
      user.email = email
      # assert user.save ... 引数がtrueの場合にテストを通す。
      assert user.save
    end

    # 間違った書式の時はerrorを吐くかテスト
    impossible_email = %w(aaa, a.ex.com, メール@ex.com, a~a@ex.com, a@|.com, a@ex., .a@ex.com, a＠ex.com, Ａ@ex.com,a@?,com,１@ex.com,"a"@ex.com, a@ex@co.jp)
    impossible_email.each do |email|
      user.email = email
      user.save
      format_msg = %w(メールアドレスは不正な値です)
      assert_equal(format_msg, user.errors.full_messages)
    end
  end

  # email小文字化テスト
  test "email_downcase" do
    email = "USER@EXAMPLE.COM"
    user = User.new(email: email)
    user.save
    # バリデーション実行後のユーザーメールアドレスと、小文字にしたemailが一致していればテストが通る。
    assert user.email == email.downcase
  end

  # アクティブユーザーがいない場合、同じメールアドレスが登録できているか 3人作成できるか
  test "active_user_uniqueness" do
    email = "test@example.com"
    count = 3

    assert_difference("User.count", count) do
      count.times do |n|
        User.create(name: "test", email: email, password: "password")
      end
    end

    # ユーザをアクティブにさせる
    active_user = User.find_by(email: email)
    active_user.update!(activated: true)
    assert active_user.activated

    # assert_no_difference: ブロック内の処理を実行した結果、引数の数に変化がなければテストを通します。
    assert_no_difference("User.count") do
      user = User.new(name: "test", email: email, password: "password")
      user.save
      uniqueness_msg = %w(メールアドレスはすでに存在します)
      assert_equal(uniqueness_msg, user.errors.full_messages)
    end

    # アクティブユーザがいなくなった場合、ユーザは保存できるか 引数1が変わらなかったら通す
    active_user.destroy!
    assert_difference("User.count", 1) do
      User.create(name: "test", email: email, password: "password")
    end

    # 一意性は保たれているか
    assert_equal(1, User.where(email: email, activated: true).count)
  end

  # パスワードテスト
  test "password_validation" do
    # 入力必須
    user = User.new(name: "test", email: "test@example.com")
    user.save
    required_msg = ["パスワードを入力してください"]
    assert_equal(required_msg, user.errors.full_messages)

    # min文字以上
    min = 8
    user.password = "a" * (min - 1)
    user.save
    minlength_msg = %w(パスワードは8文字以上で入力してください)
    assert_equal(minlength_msg, user.errors.full_messages)

    # max文字以下
    max = 72
    user.password = "a" * (max + 1) # 73
    user.save
    maxlength_msg = %w(パスワードは72文字以内で入力してください)
    assert_equal(maxlength_msg, user.errors.full_messages)

    # 書式チェック VALID_PASSWORD_REGEX = /\A[\w\-]+\z/
    possible_passwords = %w(pass---word, ________, 12341234, ____pass, pass----,PASSWORD)

    # 可能なパスワード
    possible_passwords.each do |pass|
      user.password = pass
      assert user.save
    end

    # 不可能なパスワード
    impossible_passwords = %w(pass/word, pass.word, |~=?+"a", １２３４５６７８, ＡＢＣＤＥＦＧＨ, password@)
    format_msg = ["パスワードは半角英数字•ﾊｲﾌﾝ•ｱﾝﾀﾞｰﾊﾞｰが使えます"]
    impossible_passwords_passwords.each do |pass|
      user.password = pass
      user.save
      assert_equal(format_msg, user.errors.full_messages)
    end
  end
end
