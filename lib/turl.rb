require 'twitter'
require 'logger'
require 'pathname'
require 'active_record'

require "turl/version"
require 'turl/collect'
require 'turl/application_record'
require 'turl/link'

module Turl
  CACHE_PATH = Pathname('~/.cache/turl').expand_path
  DATABASE_PATH = CACHE_PATH / 'db.sqlite3'

  def self.prepare_database!
    CACHE_PATH.mkpath
    ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: DATABASE_PATH.to_s)
    unless DATABASE_PATH.exist?
      ActiveRecord::Base.connection.execute(<<~SQL)
        create table links (
          id integer primary key,
          url text not null,
          tweet_id integer not null,
          created_at datetime not null,
          updated_at datetime not null
        );

        create unique index uniq_links_url_tweet on links(url, tweet_id);
      SQL
    end
  end
end
