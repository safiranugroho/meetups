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
      Female-Coders-Lab-Melbourne
      Melbourne-Scala-User-Group
      golang-mel
      Infrastructure-Coders
      Melbourne-Haskell-Users-Group
      devops-melbourne
      AWS-AUS
      MelbourneMUG
      Docker-Melbourne-Australia
      AngularJS-Melbourne
      Meteor-Melbourne
      gdg-melbourne
      Melbourne-Python-Meetup-Group
      Swift-Devs-Melbourne
      Melbourne-Apache-Spark-Meetup
      React-Melbourne
      scrum-12
      Agile-Project-Managers-Melbourne
      Agile-Business-Analysts-Melbourne
      Application-Security-OWASP-Melbourne
      Big-Data-Analytics-Meetup-Group
      Ruby-On-Rails-Oceania-Melbourne
      hack-for-privacy
      BuzzConf
      Melbourne-Java-JVM-Users-Group
      AgileCoach
      Kanban-Melbourne
      Melbourne-Lean-Change-Management-Meetup
      Cynefin-Melbourne-Meetup-Group
      Responsive-Org-Melbourne
      CTO-School-Melbourne
      Product-Anonymous-Meetup-Melbourne
      ProductTank-Melbourne
      Melbourne-Lean-Coffee
      Visual-Friends-Australasia
      Design-Thinking-and-Business-Innovation-Melbourne
      SecTalks-Melbourne
      Melbourne-VR
      The-UX-Design-Group-of-Melbourne
      Melbourne-CocoaHeads
      PyLadies-Melbourne
      Melbourne-Functional-User-Group-MFUG
      ThoughtWorks-Melbourne
      Melbourne-Blender-Society
      Machine-Learning-AI-Meetup
      Data-Engineering-Melbourne
      melbnlp
      Melbourne-Women-in-Machine-Learning-and-Data-Science
      Melbourne-DevSecOps-User-Group
      Melbourne-Kubernetes-Meetup
      GDG-Cloud-Melbourne
      Melbourne-Creative-AI-Meetup
      melbourne-search
      codelikeagirlau
      Women-Who-Code-Melbourne
      Disruptors-In-Tech-Melb
      DDD-Melbourne-By-Night
      Elm-Melbourne
      Melbourne-ML-AI-Bookclub
      Melbourne-Kotlin-Meetup
      Junior-Developers-Melbourne
      Melbourne-Docker-User-Group
      the-web
      Melbourne-NET-User-Group
      Cyberspectrum-Melbourne
      Enterprise-Data-Science-Architecture
      DeepRacer-Nights
      Melbourne-APIs-Meetup
      slack-platform-community-melbourne
      GraphQL-Melbourne
      TECHLED-Melbourne
      Melbourne-PE
    ]

    get '/fetch-meetups' do
      all_events = []
      meetup_groups.each do |group|
        events_by_group = JSON.parse get_events_by_group(group)
        all_events = all_events.concat(events_by_group) unless events_by_group.instance_of? Hash
      end

      @events_by_date = sort_events_by_date(all_events) unless all_events.empty?

      email_content = File.read('./views/email_content.erb')
      output = ERB.new(email_content).result(binding)

      File.open('./views/output.html', 'w+') { |file| file.write(output) }

      erb :meetups_preview
    end
  end
end
