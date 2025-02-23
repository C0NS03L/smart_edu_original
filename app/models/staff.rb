# == Schema Information
#
# Table name: staffs
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Staff < ApplicationRecord
    belongs_to :school
    has_secure_password

    normalizes :email_address, with: ->(e) { e.strip.downcase }
    validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :password, presence: true, length: { minimum: 8, maximum: 20 }
end
