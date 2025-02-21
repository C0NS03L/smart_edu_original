require 'swagger_helper'

RSpec.describe 'sessions', type: :request do
  path '/sessions/new' do
    get('Render new session page') do
      tags 'Sessions'
      produces 'text/html'
      response(200, 'successful') { run_test! }
    end
  end

  path '/sessions' do
    post('create session') do
      tags 'Sessions'
      consumes 'application/json'
      parameter name: :credentials,
                in: :body,
                schema: {
                  type: :object,
                  properties: {
                    email_address: {
                      type: :string
                    },
                    password: {
                      type: :string
                    }
                  },
                  required: %w[email_address password]
                }

      response(302, 'redirect to after authentication url') do
        let(:credentials) { { email_address: 'user@example.com', password: 'password123' } }
        run_test!
      end

      response(429, 'rate limit exceeded') do
        let(:credentials) { { email_address: 'user@example.com', password: 'password123' } }
        before { 10.times { post '/sessions', params: { email_address: 'user@example.com', password: 'wrongpass' } } }
        run_test!
      end

      response(302, 'authentication failed, redirect to new session path') do
        let(:credentials) { { email_address: 'user@example.com', password: 'wrongpassword' } }
        run_test!
      end
    end
  end

  path '/sessions' do
    delete('destroy session') do
      tags 'Sessions'
      response(302, 'session terminated, redirect to new session path') { run_test! }
    end
  end
end
