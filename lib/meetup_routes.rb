require 'sinatra/base'
require 'json'
require 'erb'

require './helpers/meetup_helpers.rb'

module WeeklyMeetups
  class MeetupRoutes < Sinatra::Application
    enable :sessions

    set :root, File.dirname(__FILE__) + '/..'
    set :views, settings.root + '/views'

    helpers MeetupHelpers

    get '/authorize-meetup' do
      redirect 'https://secure.meetup.com/oauth2/authorize'\
              '?client_id=nin8u7bna69vbrictum1rcve4l'\
              '&response_type=code'\
              '&redirect_uri=http://localhost:4567/fetch-meetups'
    end

    get '/fetch-meetups' do
      response = get_access_token(params[:code])
      json = JSON.parse response.body

      events = JSON.parse get_upcoming_events(json['access_token'])
      @events_by_date = sort_events_by_date(events['data']['events']) unless events.empty?

      email_content = File.read('./views/email_content.erb')
      output = ERB.new(email_content).result(binding)

      File.open('./views/output.html', 'w+') { |file| file.write(output) }

      erb :meetups_preview
    end
  end
end
