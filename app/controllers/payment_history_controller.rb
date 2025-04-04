class PaymentHistoryController < ApplicationController
  before_action :authorize_principal!
  before_action :ensure_payment_schema

  def index
    @school = Current.school
    @payments = @school.payment_histories.order(payment_date: :desc)
  end

  private

  def ensure_principal
    unless current_user && current_user.is_a?(Principal)
      redirect_to root_path, alert: 'You must be logged in as a principal to view this page.'
      false
    end
  end

  def ensure_payment_schema
    # Check if the database has the required tables and columns
    unless School.column_names.include?('subscription_status') &&
             ActiveRecord::Base.connection.table_exists?(:payment_histories)
      Rails.logger.error "Payment system database schema not set up. Run 'rails db:migrate'"
      render json: {
               status: 'error',
               message: 'Payment system is not fully configured. Please contact the administrator.'
             },
             status: :service_unavailable
      false
    end
  end
end
