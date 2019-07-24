require 'dotenv/load'
require 'sinatra'
require 'googleauth'
require 'googleauth/web_user_authorizer'

module Helpers
  def authorize(request)
    authorizer = Google::Auth::WebUserAuthorizer.new
    credentials = authorizer.get_credentials(ENV['DEFAULT_USER_ID'], request)
    if credentials.nil?
      return authorizer.get_authorization_url(
        login_hint: ENV['DEFAULT_USER_ID'],
        request: request
      )
    end
    credentials
  end
end
