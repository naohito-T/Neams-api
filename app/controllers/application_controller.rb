class ApplicationController < ActionController::API
  # RailsのAPIモードではdefaultでクッキーを扱うことができない。
  include ActionController::Cookies

  include Services::Authenticator

end
