#
# @desc seddデータはテーブルに保存するデモデータのこと
#


# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# 配列作成
table_names = %w(users)

table_names.each do |table_name|
  path = Rails.root.join("db/seeds/#{Rails.env}/#{table_name}.rb")

  # ファイルが存在しない場合はdevelopディレクトリを読み込む(subはpathを書き換える)
  path = path.sub(Rails.env, "development") unless File.exist?(path)

  puts "#{table_name} seed ..."
  # require methodでファイルを読み込む。
  require path
end
