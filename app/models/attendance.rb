# == Schema Information
#
# Table name: attendances
#
#  id         :integer          not null, primary key
#  timestamp  :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  school_id  :integer          not null
#  student_id :integer          not null
#  user_id    :integer          not null
#
# Indexes
#
#  index_attendances_on_school_id   (school_id)
#  index_attendances_on_student_id  (student_id)
#  index_attendances_on_user_id     (user_id)
#
# Foreign Keys
#
#  school_id  (school_id => schools.id)
#  user_id    (user_id => users.id)
#
class Attendance < ApplicationRecord
  def self.ransackable_attributes(auth_object = nil)
    %w[created_at id school_id student_id timestamp updated_at user_id]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[school student user]
  end

  # Update this association to work with STI
  # The student_id column now references a User of type 'Student'
  belongs_to :student, -> { where(type: 'Student') }, class_name: 'User', foreign_key: 'student_id'

  # The user who recorded the attendance
  belongs_to :user

  # The school where attendance was taken
  belongs_to :school

  # Add validations if needed
  validates :timestamp, presence: true
end
