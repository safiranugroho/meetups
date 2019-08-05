require 'sinatra/base'
require 'json'
require 'erb'

require './helpers/meetup_helpers.rb'

module WeeklyMeetups
  class MeetupRoutes < Sinatra::Application
    enable :sessions

    helpers MeetupHelpers

    get '/fetch-meetups' do
      events = JSON.parse get_events_by_group 'ThoughtWorks-Melbourne'
      @event = events.first

      layout = File.read('./views/layout.erb')
      output = ERB.new(layout).result(binding)

      File.open('./views/output.html', 'w+') do |f|
        f.write output
      end

      erb :layout
    end
  end
end
