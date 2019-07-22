require "dotenv/load"
require "sinatra"
require "rmail"
require "googleauth"
require "googleauth/web_user_authorizer"
require "googleauth/stores/file_token_store"
require "google/apis/gmail_v1"

configure do
  Google::Apis::ClientOptions.default.application_name = ENV["APPLICATION_NAME"]

  enable :sessions
  set :client_id, Google::Auth::ClientId.new(ENV["GOOGLE_CLIENT_ID"], ENV["GOOGLE_CLIENT_SECRET"])
  set :token_store, Google::Auth::Stores::FileTokenStore.new(file: ENV["TOKEN_PATH"])
  set :scope, Google::Apis::GmailV1::AUTH_GMAIL_COMPOSE
end

helpers do
  def authorize
    authorizer = Google::Auth::WebUserAuthorizer.new(settings.client_id, settings.scope, settings.token_store, "/auth-callback")
    credentials = authorizer.get_credentials(ENV["DEFAULT_USER_ID"], request)
    if credentials.nil?
      redirect authorizer.get_authorization_url(login_hint: ENV["DEFAULT_USER_ID"], request: request)
    end
    credentials
  end
end

get "/" do
  service = Google::Apis::GmailV1::GmailService.new
  service.client_options.application_name = ENV["APPLICATION_NAME"]
  service.authorization = authorize

  message = RMail::Message.new
  message.header.to = ENV["EMAIL_RECIPIENT"]
  message.header.from = ENV["EMAIL_SENDER"]
  message.header.subject = ENV["EMAIL_SUBJECT"]
  message.body = "Hiya!"

  service.send_user_message(ENV["DEFAULT_USER_ID"], upload_source: StringIO.new(message.to_s), content_type: "message/rfc822")
  puts "Message sent from #{ENV["EMAIL_SENDER"]} to #{ENV["EMAIL_RECIPIENT"]}!"
end

get "/auth-callback" do
  redirect Google::Auth::WebUserAuthorizer.handle_auth_callback_deferred(request)
end
