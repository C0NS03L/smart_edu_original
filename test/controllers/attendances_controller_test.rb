require 'test_helper'

class AttendancesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @current_time = Time.new(2025, 3, 27, 8, 22, 35).utc
    travel_to @current_time

    # Use fixtures
    @admin = users(:admin_user)
    @staff = users(:staff_user)
    @student = users(:student_user)
    @school = schools(:school_one)
    @attendance = attendances(:attendance_one)
  end

  teardown { travel_back }

  test 'should redirect to login when not authenticated' do
    get attendances_url
    assert_redirected_to new_session_url
  end

  test 'should get index when logged in as staff' do
    sign_in_as(@staff)
    get attendances_url
    assert_response :success
  end

  test 'should get index when logged in as admin' do
    sign_in_as(@admin)
    get attendances_url
    assert_response :success
  end

  test 'should not get index when logged in as student' do
    sign_in_as(@student)
    get attendances_url
    assert_redirected_to student_dashboard_url
  end

  test 'should get new' do
    sign_in_as(@staff)
    get new_attendance_url
    assert_response :success
  end

  test 'should create attendance' do
    sign_in_as(@staff)

    assert_difference('Attendance.count') { post attendances_url, params: { student_id: @student.id } }
  end

  test 'should create attendance via QR code' do
    sign_in_as(@staff)

    # Update with password
    @student.update!(
      school_id: @staff.school_id,
      uid: 'student-test-uid-123',
      password: 'password123', # Include password
      password_confirmation: 'password123' # Include confirmation if needed
    )

    assert_difference('Attendance.count') do
      post qr_attendance_attendances_url, params: { attendance: { student_uid: @student.uid } }, as: :json
    end

    assert_response :created
    json_response = JSON.parse(response.body)
    assert_equal 'success', json_response['status']
  end

  test 'should fail to create attendance for student from another school via QR' do
    sign_in_as(@staff)

    other_student = users(:other_school_student)
    assert_not_equal @staff.school_id, other_student.school_id

    assert_no_difference('Attendance.count') do
      post qr_attendance_attendances_url, params: { attendance: { student_uid: other_student.uid } }, as: :json
    end

    assert_response :forbidden
    json_response = JSON.parse(response.body)
    assert_equal 'error', json_response['status']
  end

  test 'should show attendance' do
    sign_in_as(@staff)
    get attendance_url(@attendance)
    assert_response :success
  end

  test 'should get edit' do
    sign_in_as(@staff)
    get edit_attendance_url(@attendance)
    assert_response :success
  end

  test 'should update attendance' do
    sign_in_as(@staff)

    new_time = @current_time - 2.hours
    patch attendance_url(@attendance), params: { attendance: { timestamp: new_time } }

    assert_redirected_to attendance_url(@attendance)
    @attendance.reload
    assert_in_delta new_time.to_i, @attendance.timestamp.to_i, 1.0
  end

  test 'should destroy attendance' do
    sign_in_as(@admin)

    assert_difference('Attendance.count', -1) { delete attendance_url(@attendance) }

    assert_redirected_to attendances_url
  end
end
