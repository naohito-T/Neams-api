#
# @desc testの設定およびtestするところ。わけるべき？
#


ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

class ActiveSupport::TestCase

  # デフォルトではfixtureを使うためseedに切り替える
  parallelize_setup do |worker|
    load "#{Rails.root}/db/seeds.rb"
  end

  # 並列テストは自動でonとなっている
  # workers: プロセス数
  # デフォルトでは:number_of_processorsには使用しているマシン(Docker)のコア数が入る
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  # fixturesを使わないため削除
  # fixtures :all

  # ユーザテーブルからアクティブなユーザを一人取り出す。
  def active_user
    User.find_by(activated: true)
  end

  def api_url(path = "/")
    "#{ENV["BASE_URL"]}/api/v1#{path}"
  end

  # コントローラーのJSONレスポンスを受け取る
  def response_body
    JSON.parse(@response.body)
  end

  # テスト用Cookie（Rack::Test::CookieJar Class）にトークンを保存する
  def logged_in(user)
    cookies[UserAuth.token_access_key] = user.to_token
  end

end
