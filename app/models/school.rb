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
#
class School < ApplicationRecord
  has_many :users
  has_many :students, -> { where(type: 'Student') }, class_name: 'User'
  has_one :principal, -> { where(type: 'Principal') }, class_name: 'User'
  has_many :staff, -> { where(type: 'Staff') }, class_name: 'User'
  has_many :payment_histories, dependent: :destroy

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
  def record_payment(amount, payment_method, transaction_id, card_last_digits = nil, card_type = nil)
    # Create a payment history record
    payment =
      payment_histories.create!(
        amount: amount,
        payment_date: Time.current,
        payment_method: payment_method,
        transaction_id: transaction_id,
        status: 'success',
        card_last_digits: card_last_digits,
        card_type: card_type,
        subscription_plan: subscription_type,
        notes: "Payment for #{subscription_type} plan"
      )

    # Update subscription status and next payment date
    update(subscription_status: 'active', next_payment_date: 30.days.from_now)

    payment
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
