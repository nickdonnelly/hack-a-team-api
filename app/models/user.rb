class User < ApplicationRecord
  EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i

  validates :email, presence: true, format: /EMAIL_REGEX/
  validates :first_name, presence: true, length: {minimum: 2, maximum: 24}
  validates :last_name, presence: true, length: {minimum: 2, maximum: 24}
  validates :passcode, presence: true

end
