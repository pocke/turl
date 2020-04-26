module Turl
  class TwitterUser < ApplicationRecord
    has_many :tweets

    def self.from_response!(resp)
      find_or_initialize_by(twitter_id: resp.id).tap do |u|
        u.update!(screen_name: resp.screen_name)
      end
    end
  end
end
