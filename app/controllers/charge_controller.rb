require 'omise'

class ChargeController < ApplicationController
  skip_before_action :require_authentication, only: [:create]
  protect_from_forgery with: :exception

  def create
    Rails.logger.info("Charge create params: #{params.inspect}")

    if params[:principal].present? && params[:school].present?
      plan = params[:plan]
      amount = params[:amount].to_i # Cast to integer

      # Store params in session
      session[:principal_params] = params[:principal]
      session[:school_params] = params[:school]
      session[:plan] = plan
      session[:amount] = amount

      # Check for payment token/source - try multiple parameter formats
      omise_token = params[:omiseToken]
      omise_source = params[:omiseSource]

      Rails.logger.info("Token found in params: #{omise_token.present?}")
      Rails.logger.info("Token value: #{omise_token}") if omise_token.present?
      Rails.logger.info("Source value: #{omise_source}") if omise_source.present?

      handle_payment(plan, amount, omise_token, omise_source)
    else
      flash[:alert] = 'Missing required information'
      redirect_to new_principal_signup_path
    end
  end

  # Keep this method public as noted in your code
  def handle_payment(plan, amount, omise_token, omise_source)
    amount_int = amount.to_i

    if amount_int == 0
      # Free plan - go directly to account creation
      redirect_to signup_create_principal_path
    else
      if omise_token.blank? && omise_source.blank?
        # Missing payment token - send back with error
        flash[:alert] = 'Payment information is required. Please try again.'
        redirect_to principals_display_review_signup_path
      else
        # Process payment with token
        handle_paid_subscription(plan, amount_int, omise_token, omise_source)
      end
    end
  end

  private

  def handle_paid_subscription(plan, amount, omise_token, omise_source)
    begin
      Rails.logger.info("Token inside handle_payment: #{omise_token}")
      Rails.logger.info("Source inside handle_payment: #{omise_source}")

      # Set Omise API key
      Omise.api_key = 'skey_test_62unknnkqf46swrwxyn'

      # Create the charge
      charge = create_omise_charge(amount, omise_token, omise_source)

      if charge.paid
        # Store charge details in session
        session[:card_details] = extract_card_details(charge)
        flash[:notice] = 'Payment successful! Creating your account...'
        redirect_to signup_create_principal_path
      else
        # Payment failed
        error_message = "Payment failed: #{charge.failure_message || 'Unknown error'}"
        Rails.logger.error(error_message)
        flash[:alert] = error_message
        redirect_to principals_display_review_signup_path
      end
    rescue Omise::Error => e
      # Omise API error
      Rails.logger.error("Omise Error: #{e.message}")
      flash[:alert] = "Payment failed: #{e.message}"
      redirect_to principals_display_review_signup_path
    rescue StandardError => e
      # General error
      Rails.logger.error("Payment processing error: #{e.message}")
      flash[:alert] = 'Payment system error: Please try again later'
      redirect_to principals_display_review_signup_path
    end
  end

  def create_omise_charge(amount, token, source)
    # Convert amount to smallest currency unit (cents/satang)
    amount_in_satang = amount.to_i * 100

    # Handle both string and symbol keys
    principal_name =
      begin
        name =
          begin
            session[:principal_params]['name']
          rescue StandardError
            nil
          end
        name ||=
          begin
            session[:principal_params][:name]
          rescue StandardError
            'Customer'
          end
        name
      end

    school_name =
      begin
        name =
          begin
            session[:school_params]['name']
          rescue StandardError
            nil
          end
        name ||=
          begin
            session[:school_params][:name]
          rescue StandardError
            'School'
          end
        name
      end

    # Create charge parameters
    charge_params = {
      amount: amount_in_satang,
      currency: 'usd',
      description: "Subscription payment for #{principal_name} and school #{school_name}",
      capture: true
    }

    # Add token or source
    if token.present?
      charge_params[:card] = token
    elsif source.present?
      charge_params[:source] = source
    else
      raise 'Neither token nor source was provided for payment'
    end

    # Create and return the charge
    Omise::Charge.create(charge_params)
  end

  def extract_card_details(charge)
    if charge.card
      {
        last_digits: charge.card.last_digits,
        brand: charge.card.brand,
        name: charge.card.name,
        expiration_month: charge.card.expiration_month,
        expiration_year: charge.card.expiration_year,
        transaction_id: charge.id
      }
    else
      { last_digits: '0000', brand: 'Unknown', transaction_id: charge.id }
    end
  end
end
