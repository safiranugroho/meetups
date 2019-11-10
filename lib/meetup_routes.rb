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

    get '/fetch-meetups' do
      access_token_response = get_access_token(params[:code])
      json = JSON.parse access_token_response.body

      response = JSON.parse get_upcoming_events(json['access_token'])
      @events_by_date = sort_events_by_date(response['events']) unless response['events'].empty?

      email_content = File.read('./views/email_content.erb')
      output = ERB.new(email_content).result(binding)

      File.open('./views/output.html', 'w+') { |file| file.write(output) }

      erb :meetups_preview
    end
  end
end
