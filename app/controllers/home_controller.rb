class HomeController < ApplicationController
  include SchoolScopable

  def index
    @student_count = scope_to_school(Student).count
    @attendance_count = scope_to_school(Attendance).count
    @last_checkin = scope_to_school(Attendance).maximum(:timestamp)
  end
end
