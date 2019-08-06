require 'sinatra/base'
require './helpers/email_helpers.rb'

module WeeklyMeetups
  class EmailRoutes < Sinatra::Application
    Google::Apis::ClientOptions.default.application_name = 'Weekly Meetups'

    enable :sessions
    set :default_user_id, 'me'

    helpers EmailHelpers

    get '/send-meetups-via-email' do
      gmail_service = Google::Apis::GmailV1::GmailService.new

      authorise(gmail_service)
      send_email(gmail_service, compose_email)
    end

    get '/authorise-email-callback' do
      redirect Google::Auth::WebUserAuthorizer
        .handle_auth_callback_deferred(request)
    end
  end
end
