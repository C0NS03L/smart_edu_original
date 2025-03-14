# == Schema Information
#
# Table name: enrollment_codes
#
#  id           :integer          not null, primary key
#  account_type :string
#  hashed_code  :string
#  role         :string
#  usage_count  :integer
#  usage_limit  :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  school_id    :integer
#
class EnrollmentCode < ApplicationRecord
  # Ensure usage_count is initialized to 0 if not set
  after_initialize :set_defaults, unless: :persisted?

  def set_defaults
    self.usage_count ||= 0
  end

  # Check if the code can still be used
  def can_be_used?
    usage_count < usage_limit
  end

  # Increment the usage count
  def increment_usage_count!
    increment!(:usage_count)
  end
end
