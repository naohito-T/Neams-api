#
# @desc アプリ全体の設定するファイル。
#
require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
# require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module NeamsApi
  class Application < Rails::Application
    config.load_defaults 6.0

    # Railsアプリデフォルトのタイムゾーン(default 'UTC')
    # ここで設定したタイムゾーンはRailsのTimeWithZoneクラスに影響する。
    config.time_zone = ENV["TZ"] # Asia/Tokyo

    # DBの読み書きに使用するタイムゾーン(:local | UTC)
    config.active.record.default_timezone = :utc

    # i18n エラーメッセージやメールタイトルを他の言語に翻訳するi18nというモジュールがある。
    # @see https://qiita.com/shimadama/items/7e5c3d75c9a9f51abdd5
    # config.i18n.default_locale = :ja 使うか不明

    # $LOAD_PATHにautoload pathを追加しない(Zeitwerk有効時はfalseが推奨)
    # つまりconfig.add_autoload_paths_to_load_pathは、Railsが自動で読み込んでいるディレクトリパスを$LOAD_PATHに追加するかを決定します。
    # 既に読み込んでいるのなら「require」を使わなくても読み込めるのでfalseとしています。
    # また、「Zeitwerk（ツァイトベルク）」を使用するアプリケーションではfalseが推奨されています
    config.add_autoload_paths_to_load_path = false

    # api mode
    config.api_only = true
  end
end
