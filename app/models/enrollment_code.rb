# == Schema Information
#
# Table name: enrollment_codes
#
#  id           :integer          not null, primary key
#  account_type :string
#  code         :string
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

  def fully_used?
    return false if usage_limit.nil?
    usage_count >= usage_limit
  end

  def usage_percentage
    return 0 if usage_limit.nil? || usage_limit == 0
    (usage_count.to_f / usage_limit) * 100
  end
end
