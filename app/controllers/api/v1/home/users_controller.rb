class Api::V1::Home::UsersController < ApplicationController
  # user一覧を取得する
  # def index
  #   users = User.all
  #   # only: [取得するカラム名] ... as_jsonメソッドのオプション機能。
  #   render json: users.as_json(only: [:id, :name, :email, :created_at])
  # end

  def show
    render json: current_user.my_json
  end


end
