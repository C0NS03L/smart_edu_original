# == Schema Information
#
# Table name: schools
#
#  id         :integer          not null, primary key
#  address    :string
#  country    :string           not null
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class School < ApplicationRecord
  has_many :students
  has_many :users
  has_many :principals
  has_many :staff
  has_many :teachers
end
