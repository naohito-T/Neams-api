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
        namespace :test do
          resources :hello, only:[:index]
        end
      end
    end
  end
end
