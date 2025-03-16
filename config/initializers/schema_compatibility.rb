Rails.application.config.after_initialize do
  # Skip in the test environment and when running migrations
  unless Rails.env.test? || ARGV.include?('db:migrate') || ARGV.include?('db:schema:load')
    # Check if we have the payment_histories table and subscription fields on schools
    begin
      unless ActiveRecord::Base.connection.table_exists?(:payment_histories)
        Rails.logger.warn "SCHEMA WARNING: payment_histories table doesn't exist. Please run 'rails db:migrate'"
      end

      unless School.column_names.include?('subscription_status')
        Rails.logger.warn "SCHEMA WARNING: schools table is missing subscription fields. Please run 'rails db:migrate'"
      end
    rescue => e
      Rails.logger.warn "SCHEMA WARNING: Unable to verify schema compatibility: #{e.message}"
    end
  end
end
