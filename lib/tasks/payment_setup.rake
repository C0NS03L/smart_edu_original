namespace :payment_setup do
  desc 'Set up payment system database requirements'
  task setup: :environment do
    puts 'Setting up payment system...'

    # Check if migrations need to be run
    if !ActiveRecord::Base.connection.table_exists?(:payment_histories) ||
         !School.column_names.include?('subscription_status')
      puts 'Running required migrations...'
      Rake::Task['db:migrate'].invoke
    else
      puts 'Database schema is already set up.'
    end

    # Initialize existing schools with default subscription status
    if School.where(subscription_status: nil).exists?
      puts 'Initializing existing schools with default subscription status...'
      School.where(subscription_status: nil).update_all(subscription_status: 'pending', student_limit: 0)
      puts "#{School.count} schools updated."
    end

    puts 'Payment system setup complete!'
  end
end
