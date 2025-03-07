require 'application_system_test_case'

class AttendancesTest < ApplicationSystemTestCase
  setup do
    @attendance = attendances(:attendance_1)
    @existing_student = students(:student_1)
    login
  end

  test 'visiting the index' do
    visit attendances_url
    assert_selector 'h4 span', text: 'Attendances'
  end

  # DEPRECATED: This test is no longer needed as the search bar now search for name
  # test 'searches attendances by student id' do
  #   visit attendances_url
  #   fill_in 'Student ID', with: @attendance.student_id
  #   assert_text @attendance.student_id, wait: 1
  # end
  #

  test 'searches attendances by student name' do
    visit attendances_url
    fill_in 'Search by name', with: 'Student 1'
    assert_text 'Student 1', wait: 1
  end

  test 'should create attendance' do
    visit new_attendance_url
    within 'tr[data-content="Student 6"]' do
      click_on 'Check-in'
    end
    first_row = 'table#latest-attendances tbody tr:first-of-type td:first-of-type'
    assert_selector first_row, text: 'Student 6'
  end

  test 'qr code check-in for existing student' do
    visit qr_index_path
    execute_script("onScanSuccess('#{@existing_student.uid}')")
    assert_text 'Attendance Logged', wait: 1
    assert_text @existing_student.name
  end

  test 'qr code check-in for non-existing student' do
    visit qr_index_path
    execute_script("onScanSuccess('non_existing_uid')")
    assert_text 'Student not found', wait: 1
  end
end
