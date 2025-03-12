# # This file contains seed data for development and testing
# # Clear existing data to avoid duplicates
# puts 'Cleaning database...'
# Session.destroy_all
# Attendance.destroy_all
# Student.destroy_all
# Staff.destroy_all
# Principal.destroy_all
# SystemAdmin.destroy_all
# User.destroy_all
# EnrollmentCode.destroy_all
# School.destroy_all
# # Create Schools
# puts 'Creating schools...'
# schools = [
#   { name: 'Lincoln High School', address: '123 Education St, Lincoln', country: 'USA' },
#   { name: 'Washington Academy', address: '456 Learning Ave, Washington', country: 'USA' },
#   { name: 'Kennedy Institute', address: '789 Knowledge Blvd, Kennedy', country: 'Canada' }
# ]
# created_schools = schools.map { |school| School.create!(school) }
# # Create System Admin
# puts 'Creating system admin...'
# SystemAdmin.create!(
#   name: 'System Administrator',
#   email_address: 'admin@smartedu.com',
#   password: 'password123',
#   password_confirmation: 'password123'
# )
# # Create Users, Principals, Staff and Students for each school
# puts 'Creating users, principals, staff, and students...'
# created_schools.each do |school|

#   # Create principal (one per school)
#   user =
#     User.create!(
#       email_address: "principal@#{school.name.downcase.gsub(' ', '')}.edu",
#       password: 'password123',
#       password_confirmation: 'password123',
#       school: school
#     )

#   principal =
#     Principal.create!(
#       name: "Principal #{school.name.split.first}",
#       email_address: "principal@#{school.name.downcase.gsub(' ', '')}.edu",
#       password: 'password123',
#       password_confirmation: 'password123',
#       school: school,
#       phone_number: '+1 555-555-5555'
#     )

#   # Create staff members
#   2.times do |i|
#     user =
#       User.create!(
#         email_address: "teacher#{i + 1}@#{school.name.downcase.gsub(' ', '')}.edu",

#   # Create some users for the school
#   5.times do |i|
#     # Create principal (one per school)
#     if i == 0
#       user =
#         User.create!(
#           email_address: "principal@#{school.name.downcase.gsub(' ', '')}.edu",
#           password: 'password123',
#           password_confirmation: 'password123',
#           school: school
#         )
#       Principal.create!(
#         name: "Principal #{school.name.split.first}",
#         email_address: "principal@#{school.name.downcase.gsub(' ', '')}.edu",
#         password: 'password123',
#         password_confirmation: 'password123',
#         school: school,
#         user_id: user.id
#       )
#       # Create staff
#     elsif i < 3
#       user =
#         User.create!(
#           email_address: "teacher#{i}@#{school.name.downcase.gsub(' ', '')}.edu",
#           password: 'password123',
#           password_confirmation: 'password123',
#           school: school
#         )
#       Staff.create!(
#         name: "Teacher #{i} #{school.name.split.first}",
#         email_address: "teacher#{i}@#{school.name.downcase.gsub(' ', '')}.edu",
#         password: 'password123',
#         password_confirmation: 'password123',
#         school: school
#       )

#     Staff.create!(
#       name: "Teacher #{i + 1} #{school.name.split.first}",
#       email_address: "teacher#{i + 1}@#{school.name.downcase.gsub(' ', '')}.edu",
#       password: 'password123',
#       password_confirmation: 'password123',
#       school: school
#     )
#   end
#   # Create students
#   10.times do |i|
#     user =
#       User.create!(
#         email_address: "student#{i}@#{school.name.downcase.gsub(' ', '')}.edu",
#         password: 'password123',
#         password_confirmation: 'password123',
#         school: school
#       )
#     Student.create!(
#       name: "Student #{i}",
#       uid: "S#{school.id}#{format('%03d', i)}",
#       email_address: "student#{i}@#{school.name.downcase.gsub(' ', '')}.edu",
#       password: 'password123',
#       password_confirmation: 'password123',
#       school: school
#     )
#   end


#   # Create enrollment codes
#   EnrollmentCode.create!(
#     hashed_code: Digest::SHA256.hexdigest("teacher-#{school.id}"),
#     role: 'teacher',
#     school_id: school.id,
#     usage_limit: 10,
#     usage_count: 0,
#     account_type: 'staff'
#   )
#   EnrollmentCode.create!(
#     hashed_code: Digest::SHA256.hexdigest("student-#{school.id}"),
#     role: 'student',
#     school_id: school.id,
#     usage_limit: 50,
#     usage_count: 0,
#     account_type: 'student'
#   )
# end
# # Create attendance records
# puts 'Creating attendance records...'
# Student.all.each do |student|
#   staff = Staff.where(school: student.school).sample

#   # Find the corresponding user for the staff
#   user = User.find_by(email_address: staff.email_address)

#   # Create 5 attendance records per student
#   5.times do |i|
#     Attendance.create!(
#       student: student,
#       timestamp: Date.today - i.days - rand(1..5).hours,
#       user_id: user.id,
#       school: student.school
#     )
#   end
# end

# # Create sessions with new fields
# puts 'Creating sessions...'
# User
#   .limit(10)
#   .each do |user|
#     # Determine which type of user this is
#     principal = Principal.find_by(email_address: user.email_address)
#     staff = Staff.find_by(email_address: user.email_address)
#     student = Student.find_by(email_address: user.email_address)

#     Session.create!(
#       user: user,
#       ip_address: "192.168.1.#{rand(1..255)}",
#       user_agent: %w[Chrome/112.0 Firefox/98.0 Safari/15.0].sample,
#       principal: principal,
#       staff: staff,
#       student: student
#     )
#   end

# # Create sessions
# # puts 'Creating sessions...'
# # User
# #   .limit(10)
# #   .each do |user|
# #     Session.create!(
# #       user: user,
# #       ip_address: "192.168.1.#{rand(1..255)}",
# #       user_agent: %w[Chrome/112.0 Firefox/98.0 Safari/15.0].sample
# #     )
# #   end
# puts 'Seed completed! Created:'
# puts "- #{School.count} schools"
# puts "- #{SystemAdmin.count} system admins"
# puts "- #{User.count} users"
# puts "- #{Principal.count} principals"
# puts "- #{Staff.count} staff members"
# puts "- #{Student.count} students"
# puts "- #{EnrollmentCode.count} enrollment codes"
# puts "- #{Attendance.count} attendance records"
# puts "- #{Session.count} sessions"
# # Print login details for all users
# puts "\nLogin Details:"
# puts "=============\n"
# puts 'System Admin: admin@smartedu.com / password123'
# puts "\nPrincipals:"
# Principal.all.each { |principal| puts "- #{principal.name}: #{principal.email_address} / password123" }
# puts "\nStaff:"
# Staff.all.each { |staff| puts "- #{staff.name}: #{staff.email_address} / password123" }
# puts "\nStudents (sample of 5):"
# Student.limit(5).each { |student| puts "- #{student.name}: #{student.email_address} / password123" }
# puts "\nEnrollment Codes:"
# School.all.each do |school|
#   puts "- #{school.name}:"
#   puts "  - Teacher code: #{Digest::SHA256.hexdigest("teacher-#{school.id}")}"
#   puts "  - Student code: #{Digest::SHA256.hexdigest("student-#{school.id}")}"
# end
