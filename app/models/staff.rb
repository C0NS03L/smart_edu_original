# == Schema Information
#
# Table name: staffs
#
#  id              :integer          not null, primary key
#  email_address   :string           not null
#  name            :string           not null
#  password_digest :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  school_id       :integer
#
# Indexes
#
#  index_staffs_on_email_address  (email_address) UNIQUE
#  index_staffs_on_school_id      (school_id)
#
# Foreign Keys
#
#  school_id  (school_id => schools.id)
#
class Staff < ApplicationRecord
  belongs_to :school
  has_secure_password
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }
  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: 8, maximum: 20 }

  def self.generate_enrollment_code(account_type)
    prefix =
      case account_type
      when 'student'
        'STU'
      else
        'GEN'
      end
    raw_code = "#{prefix}-#{SecureRandom.hex(4).upcase}"
    hashed_code = Digest::SHA256.hexdigest(raw_code)
    { raw_code: raw_code, hashed_code: hashed_code }
  end
end
