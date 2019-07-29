require 'sinatra/base'

require './lib/gmail_auth.rb'
require './lib/meetup_auth.rb'

module WeeklyMeetups
  class App < Sinatra::Application
    use GmailAuth
    use MeetupAuth

    get '/' do
      redirect '/authorize-meetup'
    end
  end
end
