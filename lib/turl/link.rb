module Turl
  class Link < ApplicationRecord
    has_many :tweet_links
    has_many :tweets, through: :tweet_links

    # TODO: Make it configurable
    def self.ignored?(url)
      url.expanded_url.host == 'twitter.com'
    end

    def self.from_response!(resp, tweet)
      url = resp.expanded_url.to_s
      find_or_initialize_by(normalized_url: normalize(url)).tap do |u|
        if u.new_record?
          begin
            title = URI.open(u.normalized_url) do |resp|
              Nokogiri::HTML(resp.read).title
            end
          rescue => ex
            Turl.logger.error "Error when detecting title for #{u.normalized_url}: #{ex}"
          end

          u.update!(
            title: title,
          )
        else
          u.save!
        end

        u.tweets << tweet unless u.tweets.include?(tweet)
      end
    end

    # TODO: implement
    def self.normalize(url)
      url
    end
  end
end
