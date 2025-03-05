namespace :enrollment do
  def generate_enrollment_codes(role, count, school_id)
    count.times do
      codes = User.generate_enrollment_code
      puts "#{role.capitalize} Raw Code: #{codes[:raw_code]}, Hashed Code: #{codes[:hashed_code]}"
      EnrollmentCode.create!(hashed_code: codes[:hashed_code], role: role, school_id: school_id, usage_count: 0)
    end
  end

  desc 'Generate enrollment codes for principals'
  task generate_principal_codes: :environment do
    school_id = ENV['SCHOOL_ID'].to_i
    generate_enrollment_codes('principal', 10, school_id)
  end

  desc 'Generate enrollment codes for teachers'
  task generate_teacher_codes: :environment do
    school_id = ENV['SCHOOL_ID'].to_i
    generate_enrollment_codes('teacher', 10, school_id)
  end

  desc 'Generate enrollment codes for students'
  task generate_student_codes: :environment do
    school_id = ENV['SCHOOL_ID'].to_i
    generate_enrollment_codes('student', 10, school_id)
  end

  desc 'Generate enrollment codes for a specified role and count'
  task generate_codes: :environment do
    role = ENV['ROLE']
    count = ENV['COUNT'].to_i
    school_id = ENV['SCHOOL_ID'].to_i
    if role && count > 0 && school_id > 0
      generate_enrollment_codes(role, count, school_id)
    else
      puts 'Eg: rake enrollment:generate_codes ROLE=teacher COUNT=5 SCHOOL_ID=1'
    end
  end
end
