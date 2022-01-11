FROM ruby:2.7.1-alpine
# ARG Dockerfile内で使用する変数名。docker-compose.yml内で指定する
# docker単体のbuildでも環境変数は渡せる。
# default値を設定できる。ARG hoge="hoge"
ARG WORKDIR
ARG RACK_ENV
ARG RAILS_ENV
ARG RAILS_LOG_TO_STDOUT
ARG RAILS_SERVE_STATIC_FILES
ARG RAILS_MASTER_KEY
ARG LANG
ARG TZ

# Dockerイメージで使用する環境変数を指定します。
# ENVを使って設定した環境変数は、イメージからコンテナへ渡されます。
# コンテナへ渡されると、コンテナ内で起動したアプリケーションで参照することができます。
ENV RUNTIME_PACKAGES="linux-headers libxml2-dev make gcc libc-dev nodejs tzdata postgresql-dev postgresql git" \
    DEV_PACKAGES="build-base curl-dev" \
    HOME=/${WORKDIR} \
    LANG=/${LANG} \
    TZ=/${TZ} \
    RACK_ENV=/${RACK_ENV} \
    RAILS_ENV=/${RAILS_ENV} \
    RAILS_LOG_TO_STDOUT=/${RAILS_LOG_TO_STDOUT} \
    RAILS_SERVE_STATIC_FILES=/${RAILS_SERVE_STATIC_FILES} \
    RAILS_MASTER_KEY=/${RAILS_MASTER_KEY}
# ここで指定したディレクトリパスの中にRailsアプリが作成されます。
WORKDIR ${HOME}
# ローカルファイルにあるGemfileをコピーする。
COPY Gemfile* ./
# ベースイメージに対して何らかのコマンドを実行する場合に使用する。
# apk update : 利用可能なパッケージの最新リストを取得するためのコマンド。
# apk upgrade : インストールされているパッケージをアップグレードする。
# apk --virtual : --virtualを指定してパッケージをインストールできるが、このオプションで仮の名前をつけてインストールすれば後でそれらを仮の名前で一括削除できる。
# apk add : パッケージをインストールするコマンド
# bundle install -j4 : --jobs=4の別名。並列処理でインストールが高速化される。
# apk del : build-baseとcurl-devはRailsの起動自体に必要がないため削除している。
RUN apk update && \
    apk upgrade && \
    apk add --no-cache ${RUNTIME_PACKAGES} && \
    apk add --virtual build-dependencies --no-cache ${DEV_PACKAGES} && \
    bundle install -j4 && \
    apk del build-dependencies
# ローカルにある全てのファイルをイメージにコピーしています(これ除外なにか除外しないとイメージが軽くならない)
COPY . .
# 生成されたコンテナ内で実行したいコマンドを指定します
# rails s -b 0.0.0.0というコマンドはRailsのプロセスをipアドレス0.0.0.0だけではなく、仮想マシンが持っている全てのipアドレスにバインディングしているという意味です。
# そのため、外部からアクセスできない、127.0.0.1だけではなく、外部からアクセスできる他のipアドレス（192.168.??.??）などにもバインディングされているため、仮想マシン内からだけではなく仮想マシンの外からもアクセスできます。
CMD ["rails", "server", "-b", "0.0.0.0"]
##############################################
#################  MEMO  #####################
##############################################
# @see https://qiita.com/daichi41/items/dfea6195cbb7b24f3419
# Dockerfile @see https://blog.cloud-acct.com/posts/u-rails-dockerfile
# [RUN] コマンドの実行。
# [ENTRYPOINT] 一番最初に実行するコマンド
# [CMD] イメージ内部のソフトウェア実行（つまりRailsのことですね）
# --virtualオプション <名前>
# addコマンドのオプションです。
# このオプションを付けてインストールしたパッケージは、一まとめにされ、新たなパッケージとして扱うことができます。
# パッケージのパッケージ化、ヘルプでは「仮想パッケージ」と呼んでいます。
# この仮想パッケージを呼び出すには、指定した<名前>で呼び出します。
# ここではbuild-dependenciesと言う名前を付けています。
# 実行した後に削除する、いわゆる「使い捨てパッケージ」をインストールする場合に良く使われます。
