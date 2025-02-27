# app/models/concerns/current.rb
class Current < ActiveSupport::CurrentAttributes
  attribute :session
  attribute :user
  attribute :school

  def user=(user)
    super
    self.school = user.school
  end
end
