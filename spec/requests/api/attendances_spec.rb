require 'swagger_helper'

RSpec.describe 'attendances', type: :request do
  path '/attendances' do
    get('Render attendances page') do
      tags 'Attendances'
      produces 'text/html'

      response(200, 'successful') { run_test! }
    end

    post('create attendance') do
      tags 'Attendances'
      consumes 'application/json'
      parameter name: :attendance,
                in: :body,
                schema: {
                  type: :object,
                  properties: {
                    student_id: {
                      type: :integer
                    }
                  },
                  required: ['student_id']
                }

      response(201, 'created') do
        let(:attendance) { { student_id: 1 } }
        run_test!
      end

      response(422, 'unprocessable entity') do
        let(:attendance) { { student_id: nil } }
        run_test!
      end
    end
  end

  path '/attendances/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show attendance') do
      tags 'Attendances'
      produces 'application/json'
      response(200, 'successful') do
        let(:id) { '1' }
        run_test!
      end
    end

    patch('update attendance') do
      tags 'Attendances'
      consumes 'application/json'
      parameter name: :attendance,
                in: :body,
                schema: {
                  type: :object,
                  properties: {
                    student_id: {
                      type: :integer
                    }
                  },
                  required: ['student_id']
                }

      response(200, 'successful') do
        let(:id) { '1' }
        let(:attendance) { { student_id: 1 } }
        run_test!
      end
    end

    delete('delete attendance') do
      tags 'Attendances'
      response(204, 'no content') do
        let(:id) { '1' }
        run_test!
      end
    end
  end
end
