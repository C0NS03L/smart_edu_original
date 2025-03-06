class Current < ActiveSupport::CurrentAttributes
  delegate :user, to: :session, allow_nil: true

  attribute :session
  attribute :user
  attribute :principal
  attribute :staff
  attribute :student
  attribute :system_admin
  attribute :school
end
