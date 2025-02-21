require 'swagger_helper'

RSpec.describe 'students', type: :request do
  path '/students' do
    get('Render student page') do
      tags 'Students'
      produces 'text/html'
      response(200, 'successful') { run_test! }
    end

    post('create student') do
      tags 'Students'
      consumes 'application/json'
      parameter name: :student,
                in: :body,
                schema: {
                  type: :object,
                  properties: {
                    name: {
                      type: :string
                    }
                  },
                  required: ['name']
                }

      response(201, 'created') do
        let(:student) { { name: 'John Doe' } }
        run_test!
      end

      response(422, 'unprocessable entity') do
        let(:student) { { name: '' } }
        run_test!
      end
    end
  end

  path '/students/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'Student ID'

    get('show student') do
      tags 'Students'
      produces 'application/json'

      response(200, 'successful') do
        let(:id) { '1' }
        run_test!
      end
    end

    patch('update student') do
      tags 'Students'
      consumes 'application/json'
      parameter name: :student,
                in: :body,
                schema: {
                  type: :object,
                  properties: {
                    name: {
                      type: :string
                    }
                  },
                  required: ['name']
                }

      response(200, 'successful') do
        let(:id) { '1' }
        let(:student) { { name: 'Updated Name' } }
        run_test!
      end

      response(422, 'unprocessable entity') do
        let(:id) { '1' }
        let(:student) { { name: '' } }
        run_test!
      end
    end

    delete('delete student') do
      tags 'Students'
      response(204, 'no content') do
        let(:id) { '1' }
        run_test!
      end
    end
  end
end
