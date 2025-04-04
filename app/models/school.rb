# == Schema Information
#
# Table name: schools
#
#  id                  :integer          not null, primary key
#  address             :string
#  country             :string           default("Unknown"), not null
#  custom_theme        :text
#  name                :string           not null
#  next_payment_date   :datetime
#  student_limit       :integer          default(0)
#  subscription_status :string           default("pending")
#  subscription_type   :string
#  theme               :string
#  theme_mode          :string
#  timezone            :string           default("Asia/Bangkok")
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  principal_id        :integer
#
# Indexes
#
#  index_schools_on_principal_id  (principal_id)
#
# Foreign Keys
#
#  principal_id  (principal_id => users.id)
#
class School < ApplicationRecord
  has_many :users
  has_many :students, -> { where(type: 'Student') }, class_name: 'User'
  has_one :principal, -> { where(type: 'Principal') }, class_name: 'User'
  has_many :staff, -> { where(type: 'Staff') }, class_name: 'User'
  has_many :payment_histories, dependent: :destroy
  belongs_to :principal, class_name: 'User', optional: true

  # Define subscription status options
  SUBSCRIPTION_STATUSES = %w[pending active trial overdue cancelled].freeze
  # Only validate for new records or when subscription_status is changed
  validates :subscription_status,
            inclusion: {
              in: SUBSCRIPTION_STATUSES
            },
            allow_nil: true,
            if: -> { subscription_status_changed? || new_record? }

  # Define subscription plan types
  SUBSCRIPTION_TYPES = %w[free_trial 500_students 1000_students].freeze

  # Check if the subscription is active
  def subscription_active?
    subscription_status == 'active' || subscription_status == 'trial'
  end

  # Check if payment is overdue
  def payment_overdue?
    subscription_status == 'overdue'
  end

  # Update subscription status based on payment
  def record_payment(amount, payment_method, transaction_id = nil, last_digits = nil, card_brand = nil)
    # Create a payment record using PaymentHistory instead of Payment
    PaymentHistory.create(
      school: self,
      amount: amount,
      payment_date: Time.current,
      payment_method: payment_method,
      transaction_id: transaction_id,
      card_last_digits: last_digits,
      card_type: card_brand,
      status: 'success',
      subscription_plan: subscription_type
    )
  end

  # Update student limit based on subscription type
  def set_plan_limits(tier)
    case tier
    when 'free_trial'
      self.student_limit = 200
      self.subscription_type = 'trial'
      self.subscription_status = 'active'
    when '500_students'
      self.student_limit = 500
      self.subscription_type = 'standard'
      self.subscription_status = 'active'
    when '1000_students'
      self.student_limit = 1000
      self.subscription_type = 'premium'
      self.subscription_status = 'active'
    end
    save
  end
end
