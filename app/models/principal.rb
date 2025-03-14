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
class Principal < User
  validates :name, presence: true
  validates :phone_number, presence: true

  def self.generate_enrollment_code(account_type)
    prefix =
      case account_type
      when 'student'
        'STU'
      when 'staff'
        'STA'
      else
        'GEN'
      end
    raw_code = "#{prefix}-#{SecureRandom.hex(4).upcase}"
    hashed_code = Digest::SHA256.hexdigest(raw_code)
    { raw_code: raw_code, hashed_code: hashed_code }
  end
end
