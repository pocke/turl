require 'sinatra/base'

module Turl
  class Web
    def self.run(argv)
      Turl.prepare_database!
      self.new.run(argv)
    end

    def run(argv)
      App.run!
    end

    class App < Sinatra::Base
      get '/' do
        res = +''
        res << '<ul>'
        Link.where('updated_at > ?', 1.week.ago).order(updated_at: :desc).each do |link|
          res << "<li>"
          res << %Q!<a href="#{link.normalized_url}">#{link.title}<br /><small>#{link.normalized_url}</small></a>!
          res << "</li>"
        end
        res << '</ul>'
        res
      end
    end
  end
end
