#
# @desc
#

10.times do |n|
  # ローカル変数か？(ブロックの中はローカルになるのか？)
  name = "user#{n}"
  email = "#{name}@example.com"
  # find_or_initialize_by ユーザテーブルをfind_byで検索する。
  # ユーザーが存在する場合 ... ユーザーオブジェクトを返す。
  # 存在しない場合 ... 新しいユーザーオブジェクトを作成する。
  user = User.find_or_initialize_by(email: email, activated: true)

  if user.new_record? # もしuserが新規オブジェクトだった場合
    user.name = name
    user.password = "password"
    # オブジェクトを変更するよという慣用句 !(感嘆符)
    user.save!
  end
end

puts "users = #{User.count}"
