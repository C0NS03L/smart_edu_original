class HomeController < ApplicationController
  def index
    @student_count = Student.count
    @attendance_count = Attendance.count
    @last_checkin = Attendance.maximum(:timestamp)
  end
end
