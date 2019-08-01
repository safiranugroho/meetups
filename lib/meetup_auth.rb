require 'sinatra/base'
require 'json'
require 'erb'

require './helpers/meetup_auth_helpers.rb'

module WeeklyMeetups
  class MeetupAuth < Sinatra::Application
    enable :sessions

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
      @event = events.first

      layout = File.read('./views/layout.erb')
      output = ERB.new(layout).result(binding)

      File.open('./views/output.html', 'w+') do |f|
        f.write output
      end

      redirect '/authorize-gmail'
    end
  end
end
