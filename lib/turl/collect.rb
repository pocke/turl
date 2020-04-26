module Turl
  class Collect
    def self.run(argv)
      Turl.prepare_database!
      self.new.run(argv)
    end

    def run(argv)
      since_id = nil
      loop do
        new_since_id = fetch_and_save(since_id: since_id)
        since_id = new_since_id if new_since_id
        sleep 60
      end
    end

    def fetch_and_save(since_id:)
      logger.info "start Turl::Collect#fetch_and_save(since_id: #{since_id.inspect})"

      tweets = client.home_timeline(count: 200)
      tweets.each do |tweet|
        next if tweet.retweet?

        id = tweet.id

        tweet.urls.each do |url|
          url = url.expanded_url.to_s
          Link.create!(tweet_id: id, url: url)
        end
      end
      logger.info "done Turl::Collect#fetch_and_save(since_id: #{since_id.inspect})"
      tweets.first&.id
    end

    private def client
      @client ||= Twitter::REST::Client.new do |config|
        config.consumer_key = ENV.fetch('TURL_CONSUMER_KEY')
        config.consumer_secret = ENV.fetch('TURL_CONSUMER_SECRET')
        config.access_token = ENV.fetch('TURL_ACCESS_TOKEN')
        config.access_token_secret = ENV.fetch('TURL_ACCESS_TOKEN_SECRET')
      end
    end

    private def logger
      @logger ||= Logger.new(STDOUT)
    end
  end
end
