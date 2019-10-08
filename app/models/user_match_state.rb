class UserMatchState < ApplicationRecord
  belongs_to :match
  belongs_to :user

  enum status: { unviewed: 0, viewed: 1, contacted: 2, converted: 3 }

end
