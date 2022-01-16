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

  # Add more helper methods to be used by all tests here...
end
