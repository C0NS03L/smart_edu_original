# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  discarded_at    :datetime
#  email_address   :string           not null
#  name            :string
#  password_digest :string           not null
#  phone_number    :string
#  type            :string
#  uid             :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  school_id       :integer
#
# Indexes
#
#  index_users_on_discarded_at   (discarded_at)
#  index_users_on_email_address  (email_address) UNIQUE
#  index_users_on_school_id      (school_id)
#  index_users_on_type           (type)
#
# Foreign Keys
#
#  school_id  (school_id => schools.id)
#
class User < ApplicationRecord
  has_secure_password
  belongs_to :school
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }
  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: 8, maximum: 20 }
  validates :school, presence: true

  def self.ransackable_attributes(auth_object = nil)
    %w[created_at discarded_at email_address id name school_id type uid updated_at phone_number]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[school sessions attendances]
  end
end
