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

## Herokuにdeployしているもの

developをしている。
