class HomeController < ApplicationController
  before_action :set_role
  include SchoolScopable

  def index
    @student_count = scope_to_school(Student).count
    @attendance_count = scope_to_school(Attendance).count
    @last_checkin = scope_to_school(Attendance).maximum(:timestamp)
    set_student_dashboard_data if @role == 'student'
    set_staff_dashboard_data if @role == 'staff'
    set_principal_dashboard_data if @role == 'principal'
    @q = Student.ransack(params[:q])
    @students = @q.result(distinct: true)
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

  def set_staff_dashboard_data
    @staff_details = Current.user.staff
    @school_details = @staff_details.school
  end

  def set_principal_dashboard_data
    @principal_details = Current.user.principal
    @school_details = @principal_details.school
  end
end
