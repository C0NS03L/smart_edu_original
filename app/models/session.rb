# == Schema Information
#
# Table name: sessions
#
#  id           :integer          not null, primary key
#  ip_address   :string
#  user_agent   :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  principal_id :integer
#  staff_id     :integer
#  student_id   :integer
#  user_id      :integer
#
# Indexes
#
#  index_sessions_on_principal_id  (principal_id)
#  index_sessions_on_staff_id      (staff_id)
#  index_sessions_on_student_id    (student_id)
#  index_sessions_on_user_id       (user_id)
#
# Foreign Keys
#
#  principal_id  (principal_id => principals.id)
#  staff_id      (staff_id => staffs.id)
#  student_id    (student_id => students.id)
#  user_id       (user_id => users.id)
#
class Session < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :principal, optional: true
  belongs_to :staff, optional: true
  belongs_to :student, optional: true
end
