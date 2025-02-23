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
#
# Indexes
#
#  index_students_on_discarded_at   (discarded_at)
#  index_students_on_email_address  (email_address) UNIQUE
#
require 'test_helper'

class StudentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
