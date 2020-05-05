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
      set :erb, :escape_html => true

      get '/' do
        links = Link.where('updated_at > ?', 1.week.ago).order(updated_at: :desc)
        erb :'root.html', locals: { links: links }, layout: :'layout.html'
      end

      get '/app.css' do
        scss :app
      end
    end
  end
end
