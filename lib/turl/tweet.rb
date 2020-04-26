module Turl
  class Tweet < ApplicationRecord
    belongs_to :twitter_user
    has_many :links, through: :tweet_links

    def self.from_response!(tweet_resp)
      user = TwitterUser.from_response!(tweet_resp.user)
      find_or_initialize_by(twitter_id: tweet_resp.id).tap do |t|
        t.update!(
          content: tweet_resp.text,
          twitter_user: user,
        )
      end
    end
  end
end
