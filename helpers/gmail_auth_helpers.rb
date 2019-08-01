require 'dotenv/load'
require 'mail'
require 'googleauth'
require 'googleauth/web_user_authorizer'
require 'googleauth/stores/file_token_store'
require 'google/apis/gmail_v1'

module WeeklyMeetups
  module GmailAuthHelpers
    def authorize(gmail_service)
      scope = Google::Apis::GmailV1::AUTH_GMAIL_COMPOSE
      client_id = Google::Auth::ClientId.new(ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET'])
      token_store = Google::Auth::Stores::FileTokenStore.new(file: 'token.yaml')

      authorizer = Google::Auth::WebUserAuthorizer.new(
        client_id,
        scope,
        token_store,
        '/authorize-gmail-callback'
      )

      credentials = authorizer.get_credentials(settings.default_user_id, request)

      if credentials.nil?
        redirect authorizer.get_authorization_url(login_hint: settings.default_user_id, request: request)
      end

      gmail_service.authorization = credentials
    end

    def compose_email
      message = Mail.new do
        from    ENV['EMAIL_SENDER']
        to      ENV['EMAIL_RECIPIENT']
        subject '[MEL] Meetups this week!'

        html_part do
          content_type 'text/html; charset=UTF-8'
          body File.read('./views/output.html')
        end
      end

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
end
