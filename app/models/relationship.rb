class Relationship < ApplicationRecord
  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"

  # rails5 から必須ではなくなった
  # validates :follower_id, presence: true
  # validates :followed_id, presence: true
end
