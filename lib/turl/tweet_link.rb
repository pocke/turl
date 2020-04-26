module Turl
  class TweetLink < ApplicationRecord
    belongs_to :tweet
    belongs_to :link
  end
end
