# == Schema Information
#
# Table name: enrollment_codes
#
#  id          :integer          not null, primary key
#  hashed_code :string
#  role        :string
#  usage_count :integer
#  usage_limit :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  school_id   :integer
#
require 'test_helper'

class EnrollmentCodeTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
