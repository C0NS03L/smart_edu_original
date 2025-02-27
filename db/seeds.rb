# Current Date and Time (UTC): 2025-02-27 07:16:35
# Current User's Login: C0NS03L

# Clear existing data first
puts 'Clearing existing data...'
[Attendance, Session, Student, Teacher, Staff, Principal, SystemAdmin, User, School].each do |model|
  puts "Deleting #{model.name.pluralize}..."
  model.delete_all
end

# Create schools
puts 'Creating schools...'
schools =
  [
    { name: 'Demo School', country: 'United States', address: '123 Main Street, New York, NY 10001' },
    { name: 'Demo School 2', country: 'United States', address: '456 Oak Avenue, Boston, MA 02108' }
  ].map { |school| School.create!(school) }

puts 'Creating system admin...'
SystemAdmin.create!(email_address: 'admin@example.com', password: 'password123', name: 'System Administrator')

schools.each do |school|
  puts "Creating users for #{school.name}..."

  # Create a teacher for each school with a teacher name
  teacher_name = "Teacher #{school.id}"

  # Create user first, then teacher
  user = User.create!(email_address: "teacher@#{school.name.parameterize}.edu", password: 'password123', school: school)

  # Create teacher with its own name (not from user)
  teacher =
    Teacher.create!(email_address: user.email_address, password: 'password123', name: teacher_name, school: school)

  # Create students
  3.times do |i|
    Student.create!(
      name: "Student #{i + 1} #{school.id}",
      uid: "S#{i + 1}#{school.id.to_s.rjust(3, '0')}",
      email_address: "student#{i + 1}@#{school.name.parameterize}.edu",
      password: 'password123',
      school: school
    )
  end

  # Create attendance records using the User record
  puts "Creating attendance records for #{school.name}..."
  Student
    .where(school: school)
    .find_each do |student|
      Attendance.create!(
        student: student,
        user: user, # Use the User record instead of Teacher
        timestamp: Time.current,
        school: school
      )
    end
end

puts "\nSeeding completed successfully!"
puts "\nYou can now log in with these accounts:"
puts 'Admin: admin@example.com / password123'
puts 'Teacher: teacher@demo-school.edu / password123'
puts 'Student: student1@demo-school.edu / password123'
