# == Schema Information
#
# Table name: payment_histories
#
#  id                :integer          not null, primary key
#  amount            :decimal(10, 2)   not null
#  card_last_digits  :string
#  card_type         :string
#  notes             :text
#  payment_date      :datetime         not null
#  payment_method    :string           not null
#  status            :string           not null
#  subscription_plan :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  school_id         :integer          not null
#  transaction_id    :string
#
# Indexes
#
#  index_payment_histories_on_school_id       (school_id)
#  index_payment_histories_on_transaction_id  (transaction_id) UNIQUE
#
# Foreign Keys
#
#  school_id  (school_id => schools.id)
#
# Indexes
#   #

# Foreign Keys
#
#  school_id  (school_id => schools.id)
#
class PaymentHistory < ApplicationRecord
  belongs_to :school

  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }

  validates :payment_method, presence: true
  validates :transaction_id, uniqueness: true, allow_nil: true
  validates :status, presence: true
  validates :card_last_digits, length: { is: 4 }, allow_nil: true

  scope :successful, -> { where(status: 'success') }

  # Add a method to mask credit card info for display
  def masked_card
    return nil unless card_last_digits.present?
    "**** **** **** #{card_last_digits}"
  end
end
