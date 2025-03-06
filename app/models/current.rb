class Current < ActiveSupport::CurrentAttributes
  attribute :session
  delegate :user, to: :session, allow_nil: true

  attribute :user
  attribute :session
  attribute :school
end
