require 'swagger_helper'

RSpec.describe 'signup', type: :request do
  path '/signup/new' do
    get('Render signup page') do
      tags 'Signup'
      produces 'text/html'
      response(200, 'successful') { run_test! }
    end
  end

  path '/signup' do
    post('create signup') do
      tags 'Signup'
      consumes 'application/json'
      parameter name: :user,
                in: :body,
                schema: {
                  type: :object,
                  properties: {
                    email_address: {
                      type: :string
                    },
                    password: {
                      type: :string
                    },
                    password_confirmation: {
                      type: :string
                    }
                  },
                  required: %w[email_address password password_confirmation]
                }

      response(302, 'redirect to after authentication url') do
        let(:user) do
          { email_address: 'user@example.com', password: 'password123', password_confirmation: 'password123' }
        end
        run_test!
      end

      response(422, 'unprocessable entity') do
        let(:user) { { email_address: 'invalid', password: 'short', password_confirmation: 'mismatch' } }
        run_test!
      end
    end
  end
end
