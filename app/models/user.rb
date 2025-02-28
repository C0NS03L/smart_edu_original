# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  email_address   :string           not null
#  is_active       :boolean          default(TRUE)
#  password_digest :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_users_on_email_address  (email_address) UNIQUE
#
class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }
  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: 8, maximum: 20 }

  def self.generate_enrollment_code
    raw_code = SecureRandom.hex(8) # Generates a random 16-character string
    hashed_code = Digest::SHA256.hexdigest(raw_code)
    { raw_code: raw_code, hashed_code: hashed_code }
  end
end
