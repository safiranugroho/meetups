require 'sinatra/base'
require 'json'

require './helpers/meetup_auth_helpers.rb'

module WeeklyMeetups
  class MeetupAuth < Sinatra::Application
    enable :sessions

    # find a better way to do this
    set :views, settings.root + '/../views'

    helpers MeetupAuthHelpers

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

      events = JSON.parse get_events_by_group 'ThoughtWorks-Melbourne'
      slim :index, locals: { event: events.first }
    end
  end
end
