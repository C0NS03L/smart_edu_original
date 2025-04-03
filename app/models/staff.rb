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
class Staff < User
  validates :name, presence: true
  validates :uid, presence: true

  accepts_nested_attributes_for :school

  def self.generate_enrollment_code(account_type)
    prefix =
      case account_type
      when 'student'
        'STU'
      else
        'GEN'
      end
    "#{prefix}-#{SecureRandom.hex(4).upcase}"
  end
end
