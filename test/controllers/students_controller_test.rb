require 'test_helper'

class StudentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @student = students(:student_1)
    sign_in
  end

  # test 'should get index' do
  #   get students_url
  #   assert_response :success
  # end

  # test 'should get new' do
  #   get new_student_url
  #   assert_response :success
  # end
  # TODO: Fix this test,
  # School must exist
  # Password can't be blank
  # Email address can't be blank
  # Email address has already been taken
  # Email address is invalid
  # Password can't be blank
  # Password is too short (minimum is 8 characters)
  # Name is too short (minimum is 5 characters)
  # test 'should create student' do
  #   assert_difference('Student.count') { post students_url, params: { student: { name: 'newstudent' } } }

  #   assert_redirected_to student_url(Student.last)
  # end

  # test 'should show student' do
  #   get student_url(@student)
  #   assert_equal @controller.student.id, @student.id
  #   assert_response :success
  # end

  # test 'should get edit' do
  #   get edit_student_url(@student)
  #   assert_response :success
  # end

  # test 'should update student' do
  #   patch student_url(@student), params: { student: { name: 'newname' } }
  #   assert_redirected_to student_url(@student)
  # end

  # test 'should destroy student' do
  #   assert_difference('Student.kept.count', -1) { delete student_url(@student) }

  #   assert_redirected_to students_url
  # end
end
