require 'swagger_helper'

RSpec.describe 'passwords', type: :request do
  path '/passwords/new' do
    get('Render forget password page') do
      tags 'Passwords'
      produces 'text/html'
      response(200, 'successful') { run_test! }
    end
  end

  path '/passwords' do
    post('create password reset') do
      tags 'Passwords'
      consumes 'application/json'
      parameter name: :user,
                in: :body,
                schema: {
                  type: :object,
                  properties: {
                    email_address: {
                      type: :string
                    }
                  },
                  required: ['email_address']
                }

      response(302, 'redirect to new session') do
        let(:user) { { email_address: 'user@example.com' } }
        run_test!
      end
    end
  end

  path '/passwords/{token}/edit' do
    parameter name: 'token', in: :path, type: :string, description: 'Reset token'
    get('edit password') do
      tags 'Passwords'
      response(200, 'successful') do
        let(:token) { 'valid-token' }
        run_test!
      end
    end
  end

  path '/passwords/{token}' do
    parameter name: 'token', in: :path, type: :string, description: 'Reset token'
    patch('update password') do
      tags 'Passwords'
      consumes 'application/json'
      parameter name: :user,
                in: :body,
                schema: {
                  type: :object,
                  properties: {
                    password: {
                      type: :string
                    },
                    password_confirmation: {
                      type: :string
                    }
                  },
                  required: %w[password password_confirmation]
                }

      response(302, 'redirect to new session') do
        let(:token) { 'valid-token' }
        let(:user) { { password: 'password123', password_confirmation: 'password123' } }
        run_test!
      end

      response(422, 'unprocessable entity') do
        let(:token) { 'valid-token' }
        let(:user) { { password: 'password123', password_confirmation: 'mismatch' } }
        run_test!
      end
    end
  end
end
