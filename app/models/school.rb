# == Schema Information
#
# Table name: schools
#
#  id         :integer          not null, primary key
#  address    :string
#  country    :string           default("Unknown"), not null
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class School < ApplicationRecord
  has_many :users
  has_many :students, -> { where(type: 'Student') }, class_name: 'User'
  has_one :principal, -> { where(type: 'Principal') }, class_name: 'User'
  has_many :staff, -> { where(type: 'Staff') }, class_name: 'User'
end
