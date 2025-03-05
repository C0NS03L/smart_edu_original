# == Schema Information
#
# Table name: principals
#
#  id              :integer          not null, primary key
#  email_address   :string           not null
#  name            :string           not null
#  password_digest :string           not null
#  phone_number    :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  school_id       :integer
#  user_id         :integer          not null
#
# Indexes
#
#  index_principals_on_email_address  (email_address) UNIQUE
#  index_principals_on_school_id      (school_id)
#  index_principals_on_user_id        (user_id)
#
# Foreign Keys
#
#  school_id  (school_id => schools.id)
#  user_id    (user_id => users.id)
#
class Principal < ApplicationRecord
  belongs_to :school
  has_secure_password

  normalizes :email_address, with: ->(e) { e.strip.downcase }
  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: 8, maximum: 20 }
  validates :name, presence: true
  validates :phone_number, presence: true
end
