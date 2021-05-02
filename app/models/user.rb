class User < ApplicationRecord
  has_secure_password
  @verified = false

  def welcome
    "Hello, #{self.username}"
  end
end
