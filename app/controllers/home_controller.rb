class HomeController < ApplicationController
  # allow_unauthenticated_access only: %i[index]
  def index
    @student_count = Student.count
    @attendance_count = Attendance.count
    @last_checkin = Attendance.maximum(:timestamp)
  end
end
