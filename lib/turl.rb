require 'twitter'
require 'logger'
require 'pathname'
require 'active_record'
require 'nokogiri'
require 'open-uri'

require "turl/version"
require 'turl/collect'
require 'turl/application_record'
require 'turl/link'
require 'turl/tweet'
require 'turl/twitter_user'
require 'turl/tweet_link'

module Turl
  CACHE_PATH = Pathname('~/.cache/turl').expand_path
  DATABASE_PATH = CACHE_PATH / 'db.sqlite3'

  def self.prepare_database!
    CACHE_PATH.mkpath
    ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: DATABASE_PATH.to_s)
    unless DATABASE_PATH.exist?
      <<~SQL.split(';').select(&:present?).each { |sql| ActiveRecord::Base.connection.execute(sql) }
        create table links (
          id integer primary key,

          normalized_url text not null,
          title text,

          created_at datetime not null,
          updated_at datetime not null
        );

        create unique index uniq_links_url_tweet on links(normalized_url);

        create table tweets (
          id integer primary key,
          twitter_id text not null,

          twitter_user_id integer not null,
          content text not null,

          created_at datetime not null,
          updated_at datetime not null
        );

        create unique index uniq_tweets_twitter_id on tweets(twitter_id);

        create table tweet_links (
          id integer primary key,

          tweet_id integer not null,
          link_id integer not null,

          created_at datetime not null,
          updated_at datetime not null
        );

        create unique index uniq_tweet_links_tweet_link on tweet_links(tweet_id, link_id);

        create table twitter_users (
          id integer primary key,
          twitter_id text not null,

          screen_name text not null,

          created_at datetime not null,
          updated_at datetime not null
        );

        create unique index uniq_twitter_users_twitter_id on twitter_users(twitter_id);
      SQL
    end
  end

  def self.logger
    @logger ||= Logger.new(STDOUT)
  end
end
