# Intorduction

開発環境での作成はrootディレクトリのREADME.mdを参照してください。

[README](../README.md)

## Herokuに設定する環境変数

Dockerを使わないRailsデプロイでは、以下の環境変数が自動で設定される。

- LANG: en_US.UTF-8（ランゲージ）

- RACK_ENV: production（ラックエンブ）
Rackへ現在の環境を示す変数
Rackとは … http送受信処理を担当するモジュールのこと。

- RAILS_ENV: production（レイルズ エンブ）
Railsへ現在の環境を示す変数

- RAILS_LOG_TO_STDOUT: enabled（ログ スタンダート アウト）
logを標準で出力するか否かのフラグ。enabled = 出力する。

- RAILS_SERVE_STATIC_FILES: enabled（サーバー スタティック ファイルズ）
publicディレクトリからの静的ファイルを提供してもらう（apiモードではあんま意味ないかも）
Docker経由の場合は、自分で本番用の環境変数を設定する必要がある。

LANGについては既にDockerfileで定義しているため、その他の環境変数をconfigに定義しています。

## How To deploy ?

$ tree -L 1
.
|-- Dockerfile
|-- Gemfile
|-- Gemfile.lock
|-- Makefile
|-- README.md
|-- Rakefile
|-- api
|-- app
|   |-- model Controlleから渡させる。
|-- bin
|-- config
|-- config.ru
|-- db
|-- entrypoint.sh
|-- heroku.yml
|-- lefthook.yml
|-- lib
|-- log
|-- public
|-- storage
|-- test
|-- tmp
|-- .irbrc Rubyコンソールを実行する $libコマンド実行時に読み込まれる設定ファイル(Railsコンソール起動時にも読み込まれる)
`-- vendor

## db/migrate/*

マイグレーションファイルはテーブルの中身のカラムを作成するファイル

- マイグレーションファイル命名規則

tableを作成するやつ
create_tablename
columnを変更するやつ
change_tablename

## validation 設定確認

[参考](https://blog.cloud-acct.com/posts/u-rails-error-messages-jayml)

```sh
# api rails console へlogin
$ make api.console
# I18n.t("パス") ... 引数のパスで指定したymlファイルの値を返す。
$ I18n.t("activerecord.attributes.user")
=> {:name=>"名前", :email=>"メールアドレス", :password=>"パスワード", :activated=>"アクティブフラグ", :admin=>"管理者"}
```

## debug確認(binding.pry)

[参考](https://blog.cloud-acct.com/posts/u-rails-custom-eachvalidator)

止めたいコードのところでbinding.pryをするとコードが実行された時に止まる。

```ruby
def validate_each(record, attribute, value)
  # debug
  binding.pry # ここで止まる
end
```

- record
ユーザオブジェクト

- attribute
属性が入る。エラーメッセージにも使われる

- value
ユーザが入力した値が入る
