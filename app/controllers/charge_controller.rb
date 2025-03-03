require 'omise'

class ChargeController < ApplicationController
  protect_from_forgery with: :exception

  def create
    # Set your API keys here
    Omise.api_key = 'skey_test_62unknnkqf46swrwxyn'

    # Charge 1000.00 THB
    charge = Omise::Charge.create({ amount: 1_000_00, currency: 'thb', card: params[:omiseToken] })

    if charge.paid
      render '_success_modal'
    else
      # handle failure, send error message to user
      render '_fail_modal'
    end
  end
end
