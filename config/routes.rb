##
## @author naohito-T
## @desc アクションにアクセスするルートを追加するファイル
##
## For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

Rails.application.routes.draw do
  # namespace controllers以下のディレクトリ階層を表す
  # http://localhost:3000/api/v1/home/test/hello
  namespace :api do
    namespace :v1 do
      namespace :home do
        resources :users, only:[] do
          # ルートにidを使用しない場合に使用するオプション
          # 通常、showアクションはuser_idを必要とします。
          # => /api/v1/users/:user_id/current_user
          # このオプションをつけると、パスのuser_idが不要となります。
          # => /api/v1/users/current_user
          get :current_user, action: :show, on: :collection

          # login, logout
          resources :user_token, only: [:create] do
            delete :destroy, on: :collection
          end
        end
      end
    end
  end
end
