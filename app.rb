require 'dotenv/load'
require 'sinatra'
require 'rmail'
require 'googleauth'
require 'googleauth/web_user_authorizer'
require 'googleauth/stores/file_token_store'
require 'google/apis/gmail_v1'
require 'net/http'
require 'uri'
require 'json'

configure do
  Google::Apis::ClientOptions.default.application_name = 'Weekly Meetups'

  enable :sessions
  set :scope, Google::Apis::GmailV1::AUTH_GMAIL_COMPOSE
  set :client_id, Google::Auth::ClientId.new(ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET'])
  set :token_store, Google::Auth::Stores::FileTokenStore.new(file: ENV['TOKEN_PATH'])
end

helpers do
  def authorize(gmail_service)
    authorizer = Google::Auth::WebUserAuthorizer.new(
      settings.client_id,
      settings.scope,
      settings.token_store,
      '/authorize-gmail-callback'
    )

    credentials = authorizer.get_credentials(ENV['DEFAULT_USER_ID'], request)
    redirect authorizer.get_authorization_url(login_hint: ENV['DEFAULT_USER_ID'], request: request) if credentials.nil?

    gmail_service.authorization = credentials
  end

  def compose_email
    message = RMail::Message.new
    message.header.to = ENV['EMAIL_RECIPIENT']
    message.header.from = ENV['EMAIL_SENDER']
    message.header.subject = ENV['EMAIL_SUBJECT']
    message.body = 'Hiya!'

    message
  end

  def send_email(gmail_service, message)
    gmail_service.send_user_message(
      ENV['DEFAULT_USER_ID'],
      upload_source: StringIO.new(message.to_s),
      content_type: 'message/rfc822'
    )

    puts "Message sent from #{ENV['EMAIL_SENDER']} to #{ENV['EMAIL_RECIPIENT']}!"
  end
end

get '/authorize-gmail' do
  gmail_service = Google::Apis::GmailV1::GmailService.new

  authorize(gmail_service)
  send_email(gmail_service, compose_email)
end

get '/authorize-gmail-callback' do
  redirect Google::Auth::WebUserAuthorizer
    .handle_auth_callback_deferred(request)
end

get '/authorize-meetup' do
  redirect 'https://secure.meetup.com/oauth2/authorize'\
           "?client_id=#{ENV['MEETUP_CLIENT_ID']}"\
           '&response_type=code'\
           "&redirect_uri=#{ENV['MEETUP_CALLBACK_HOST']}/authorize-meetup-callback"
end

get '/authorize-meetup-callback' do
  puts "Meetup.com authorized- #{params[:code]}"

  header = { 'Content-Type': 'application/x-www-form-urlencoded' }
  request_body = URI.encode_www_form(
    client_id: ENV['MEETUP_CLIENT_ID'],
    client_secret: ENV['MEETUP_CLIENT_SECRET'],
    grant_type: 'authorization_code',
    redirect_uri: "#{ENV['MEETUP_CALLBACK_HOST']}/authorize-meetup-callback",
    code: params[:code]
  )

  uri = URI.parse('https://secure.meetup.com/oauth2/access')
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true

  request = Net::HTTP::Post.new(uri.request_uri, header)
  request.body = request_body

  response = http.request(request)

  puts "Meetup.com access token- #{response.body}"
end
