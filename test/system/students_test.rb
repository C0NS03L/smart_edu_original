require 'application_system_test_case'

class StudentsTest < ApplicationSystemTestCase
  # def login
  #   visit new_session_url
  #   @user = users(:one)
  #   fill_in 'email_address', with: @user.email_address
  #   fill_in 'password', with: 'password'
  #   click_on 'Sign in'
  #   assert_selector 'h4 span', text: 'Dashboard'
  # end

  # setup do
  #   @student = students(:student_1)
  #   login
  # end

  # test 'visiting the index' do
  #   visit students_url
  #   assert_selector 'h4', text: 'Students'
  # end

  # ## TODO: Fix this test
  # # test 'should create student' do
  # #   visit students_url
  # #   click_on 'New student'
  # #   fill_in 'Name', with: @student.name
  # #   click_on 'Create Student'
  # #   assert_text 'Student was successfully created'
  # # end

  # test 'searches students by name' do
  #   visit students_path
  #   fill_in 'Search by name', with: @student.name
  #   assert_text @student.name, wait: 1
  # end

  # ## TODO: Fix this test
  # # test 'should update Student' do
  # #   visit student_url(@student)
  # #   click_on 'Edit this student', match: :first

  # #   click_on 'Update Student'

  # #   assert_text 'Student was successfully updated'
  # #   click_on 'Back'
  # # end

  # test 'should destroy Student' do
  #   visit student_url(@student)
  #   accept_alert { click_on 'Destroy this student', match: :first }
  #   assert_text 'Student 1 was successfully removed.'
  # end
end
