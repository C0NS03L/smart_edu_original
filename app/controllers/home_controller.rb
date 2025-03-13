class HomeController < ApplicationController
  before_action :set_role
  include SchoolScopable

  def index
    @student_count = scope_to_school(Student).count
    @attendance_count = scope_to_school(Attendance).count
    @last_checkin = scope_to_school(Attendance).maximum(:timestamp)
    set_student_dashboard_data if @role == 'student'
  end

  private

  def set_role
    @role = Current.user.role if Current.user
  end

  def set_student_dashboard_data
    @student_details = Current.user.student
    @school_details = @student_details.school
    @attendance_history = @student_details.attendances.order(created_at: :desc).limit(10)
  end
end
