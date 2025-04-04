class Current < ActiveSupport::CurrentAttributes
  attribute :session
  attribute :user
  attribute :school

  def user=(user)
    super
    self.school = user.school if user&.school
  end

  # Helper methods to check user type
  def principal?
    user&.is_a?(Principal) || user&.type == 'Principal'
  end

  def staff?
    user&.is_a?(Staff) || user&.type == 'Staff'
  end

  def student?
    user&.is_a?(Student) || user&.type == 'Student'
  end

  def system_admin?
    user&.is_a?(SystemAdmin) || user&.type == 'SystemAdmin'
  end
end
