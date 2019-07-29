require 'sinatra/base'
require './helpers/meetup_auth_helpers.rb'

module WeeklyMeetups
  class MeetupAuth < Sinatra::Application
    enable :sessions

    helpers WeeklyMeetups::MeetupAuthHelpers

    get '/authorize-meetup' do
      redirect 'https://secure.meetup.com/oauth2/authorize'\
              "?client_id=#{ENV['MEETUP_CLIENT_ID']}"\
              '&response_type=code'\
              "&redirect_uri=#{ENV['MEETUP_CALLBACK_HOST']}/authorize-meetup-callback"
    end

    get '/authorize-meetup-callback' do
      puts "Meetup.com authorized- #{params[:code]}"

      response = get_access_token params[:code]
      puts "Meetup.com access token- #{response}"
    end
  end
end
