namespace :enrollment do
  def generate_enrollment_code_with_limit(account_type, usage_limit, school_id, generator)
    codes = generator.generate_enrollment_code(account_type)
    puts "#{account_type.capitalize} Raw Code: #{codes[:raw_code]}, Hashed Code: #{codes[:hashed_code]}"
    EnrollmentCode.create!(
      hashed_code: codes[:hashed_code],
      account_type: account_type,
      school_id: school_id,
      usage_count: 0,
      usage_limit: usage_limit
    )
  end

  desc 'Generate a single enrollment code for principals with multiple uses'
  task generate_principal_code_with_limit: :environment do
    school_id = ENV['SCHOOL_ID'].to_i
    usage_limit = ENV['USAGE_LIMIT'].to_i
    generate_enrollment_code_with_limit('principal', usage_limit, school_id, Principal)
  end

  desc 'Generate a single enrollment code for staff with multiple uses'
  task generate_staff_code_with_limit: :environment do
    school_id = ENV['SCHOOL_ID'].to_i
    usage_limit = ENV['USAGE_LIMIT'].to_i
    generate_enrollment_code_with_limit('staff', usage_limit, school_id, Principal)
  end

  desc 'Generate a single enrollment code for students with multiple uses'
  task generate_student_code_with_limit: :environment do
    school_id = ENV['SCHOOL_ID'].to_i
    usage_limit = ENV['USAGE_LIMIT'].to_i
    generator = ENV['GENERATOR'] == 'staff' ? Staff : Principal
    generate_enrollment_code_with_limit('student', usage_limit, school_id, generator)
  end

  desc 'Generate a single enrollment code for a specified account type with multiple uses'
  task generate_code_with_limit: :environment do
    account_type = ENV['ACCOUNT_TYPE']
    usage_limit = ENV['USAGE_LIMIT'].to_i
    school_id = ENV['SCHOOL_ID'].to_i
    generator = ENV['GENERATOR'] == 'staff' ? Staff : Principal
    if account_type && usage_limit > 0 && school_id > 0
      generate_enrollment_code_with_limit(account_type, usage_limit, school_id, generator)
    else
      puts 'Eg: rake enrollment:generate_code_with_limit ACCOUNT_TYPE=staff USAGE_LIMIT=5 ' \
             'SCHOOL_ID=1 GENERATOR=principal'
    end
  end
end
