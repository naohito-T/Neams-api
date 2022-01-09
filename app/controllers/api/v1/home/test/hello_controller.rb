##
##
##
##
##
##

class Api::V1::Home::Test::HelloController < ApplicationController
  def index
    render json: "Hello"
  end
end
