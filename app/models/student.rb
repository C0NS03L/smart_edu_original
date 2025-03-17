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
class Student < User
  belongs_to :school
  validates :uid, presence: true

  has_many :attendances, dependent: :destroy
  has_many :attendances, dependent: :delete_all
  has_secure_password
  has_many :sessions, dependent: :destroy

  include Discard::Model
  before_save :set_default_uid

  accepts_nested_attributes_for :school

  private

  def self.ransackable_attributes(auth_object = nil)
    %w[id name uid created_at updated_at school_id]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[school attendances]
  end

  def set_default_uid
    self.uid = SecureRandom.uuid if uid.blank?
  end
end
