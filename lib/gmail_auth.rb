require 'sinatra/base'
require 'dotenv/load'
require 'rmail'
require 'googleauth'
require 'googleauth/web_user_authorizer'
require 'googleauth/stores/file_token_store'
require 'google/apis/gmail_v1'

module WeeklyMeetups
  class GmailAuth < Sinatra::Application
    Google::Apis::ClientOptions.default.application_name = 'Weekly Meetups'

    enable :sessions
    set :scope, Google::Apis::GmailV1::AUTH_GMAIL_COMPOSE
    set :client_id, Google::Auth::ClientId.new(ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET'])
    set :token_store, Google::Auth::Stores::FileTokenStore.new(file: 'token.yaml')
    set :default_user_id, 'me'

    helpers do
      def authorize(gmail_service)
        authorizer = Google::Auth::WebUserAuthorizer.new(
          settings.client_id,
          settings.scope,
          settings.token_store,
          '/authorize-gmail-callback'
        )

        credentials = authorizer.get_credentials(settings.default_user_id, request)

        if credentials.nil?
          redirect authorizer.get_authorization_url(login_hint: settings.default_user_id, request: request)
        end

        gmail_service.authorization = credentials
      end

      def compose_email
        message = RMail::Message.new
        message.header.to = ENV['EMAIL_RECIPIENT']
        message.header.from = ENV['EMAIL_SENDER']
        message.header.subject = '[MEL] Meetups this week!'
        message.body = 'Hiya!'

        message
      end

      def send_email(gmail_service, message)
        gmail_service.send_user_message(
          settings.default_user_id,
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
  end
end
