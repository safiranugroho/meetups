require 'sinatra/base'
require 'json'
require 'erb'

require './helpers/meetup_helpers.rb'

module WeeklyMeetups
  class MeetupAuth < Sinatra::Application
    enable :sessions

    set :root, File.dirname(__FILE__) + '/..'
    set :views, settings.root + '/views'

    helpers MeetupHelpers

    get '/authorize-meetup' do
      redirect 'https://secure.meetup.com/oauth2/authorize'\
              '?client_id=nin8u7bna69vbrictum1rcve4l'\
              '&response_type=code'\
              '&redirect_uri=http://localhost:4567/authorize-meetup-callback'
    end

    get '/authorize-meetup-callback' do
      response = get_access_token(params[:code])
      json = JSON.parse response.body

      events = JSON.parse get_upcoming_events(json['access_token'])
      @events_by_date = sort_events_by_date(events['data']['events']) unless events.empty?

      erb :meetups_list_by_day
    end
  end
end
