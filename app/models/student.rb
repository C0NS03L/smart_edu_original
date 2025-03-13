# == Schema Information
#
# Table name: students
#
#  id              :integer          not null, primary key
#  discarded_at    :datetime
#  email_address   :string
#  name            :string
#  password_digest :string
#  uid             :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  school_id       :integer          not null
#
# Indexes
#
#  index_students_on_discarded_at   (discarded_at)
#  index_students_on_email_address  (email_address) UNIQUE
#  index_students_on_school_id      (school_id)
#
# Foreign Keys
#
#  school_id  (school_id => schools.id)
#
class Student < ApplicationRecord
  belongs_to :school

  has_many :attendances, dependent: :destroy
  belongs_to :user
  has_many :attendances, dependent: :delete_all
  has_secure_password
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }
  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: 8, maximum: 20 }
  validates :name, presence: true, length: { minimum: 5, maximum: 20 }

  include Discard::Model
  before_save :set_default_uid

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
