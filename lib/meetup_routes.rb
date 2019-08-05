require 'sinatra/base'
require 'json'
require 'erb'
require 'date'

require './helpers/meetup_helpers.rb'

module WeeklyMeetups
  class MeetupRoutes < Sinatra::Application
    enable :sessions

    set :root, File.dirname(__FILE__) + '/..'
    set :views, settings.root + '/views'

    helpers MeetupHelpers

    meetup_groups = %w[
      Women-Who-Code-Melbourne
      PyLadies-Melbourne
    ]

    get '/fetch-meetups' do
      @events = []
      meetup_groups.each { |group| @events = @events.concat JSON.parse get_events_by_group(group) }

      layout = File.read('./views/layout.erb')
      output = ERB.new(layout).result(binding)

      File.open('./views/output.html', 'w+') { |file| file.write(output) }

      erb :layout
    end
  end
end
