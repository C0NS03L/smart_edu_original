require 'omise'

class ChargeController < ApplicationController
  protect_from_forgery with: :exception
  before_action :ensure_payment_schema
  # Skip authentication for the create action
  skip_before_action :require_authentication, only: [:create]
  before_action :check_user_exists, only: [:create]

  def create
    # Get the parameters from the form
    amount = params[:amount].to_i
    tier = params[:tier]
    omise_token = params[:omiseToken]
    omise_source = params[:omiseSource]

    if Current.user&.school.present?
      school = Current.user.school
      handle_payment(school, tier, amount, omise_token, omise_source)
    else
      session[:pending_payment] = { amount: amount, tier: tier, omise_token: omise_token, omise_source: omise_source }

      flash[:notice] = 'Please create a principal account to complete your subscription'
      redirect_to new_principal_signup
    end
  end

  # Move the handle_payment method above the 'private' keyword
  def handle_payment(school, tier, amount, omise_token, omise_source)
    if amount == 0 && tier == 'trial'
      handle_free_trial(school, tier)
    else
      handle_paid_subscription(school, tier, amount, omise_token, omise_source)
    end
  end

  private

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

  def handle_free_trial(school, tier)
    # Set the plan limits for free trial
    school.set_plan_limits('free_trial')

    # Record the free trial as a $0 payment
    school.record_payment(0, 'free_trial', nil)

    # Flash success message
    flash[:notice] = 'Free trial activated successfully!'

    # Redirect to dashboard or appropriate page
    if Current.user&.type == 'Principal'
      redirect_to principal_dashboard_path
    else
      redirect_to root_path
    end
  end

  def handle_paid_subscription(school, tier, amount, omise_token, omise_source)
    begin
      Omise.api_key = 'skey_test_62unknnkqf46swrwxyn'

      charge = create_omise_charge(amount, omise_token, omise_source)

      if charge.paid
        card_details = extract_card_details(charge)

        school.set_plan_limits(tier)

        payment =
          school.record_payment(
            amount / 100.0,
            'credit_card',
            charge.id,
            card_details[:last_digits],
            card_details[:brand]
          )

        flash[:notice] = 'Payment successful! Your subscription is now active.'

        # Redirect based on user type
        if Current.user&.type == 'Principal'
          redirect_to principal_dashboard_path
        else
          redirect_to root_path
        end
      else
        @error_message = "Payment failed: #{charge.failure_message || 'Unknown error'}"
        Rails.logger.error("Payment failed: #{charge.failure_message}")
        render 'charge/fail_modal', layout: nil
      end
    rescue Omise::Error => e
      Rails.logger.error("Omise Error: #{e.message}")
      @error_message = "Payment failed: #{e.message}"
      render 'charge/fail_modal', layout: nil
    rescue StandardError => e
      Rails.logger.error("Payment processing error: #{e.message}")
      @error_message = 'Payment system error: Please try again later'
      render 'charge/fail_modal', layout: nil
    end
  end

  def create_omise_charge(amount, token, source)
    charge_params = {
      amount: amount,
      currency: 'usd',
      description: "Subscription payment for #{Current.user.school.name}",
      capture: true
    }

    # Use either token or source based on which one is provided
    if token.present?
      charge_params[:card] = token
    elsif source.present?
      charge_params[:source] = source
    else
      raise 'Neither token nor source was provided for payment'
    end

    Omise::Charge.create(charge_params)
  end

  def extract_card_details(charge)
    if charge.card
      {
        last_digits: charge.card.last_digits,
        brand: charge.card.brand,
        name: charge.card.name,
        expiration_month: charge.card.expiration_month,
        expiration_year: charge.card.expiration_year
      }
    else
      { last_digits: '0000', brand: 'Unknown' }
    end
  end

  # Check if user exists but don't require authentication
  def check_user_exists
    # If there's no current user, redirect directly to principal signup
    unless Current.user.present?
      session[:pending_payment] = {
        amount: params[:amount],
        tier: params[:tier],
        omise_token: params[:omiseToken],
        omise_source: params[:omiseSource]
      }

      # Redirect to principal signup instead of login
      flash[:notice] = 'Please create a principal account to complete your subscription'
      redirect_to new_principal_path
    end
  end
end
