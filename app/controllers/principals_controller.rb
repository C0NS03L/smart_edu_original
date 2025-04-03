class PrincipalsController < ApplicationController
  def generate_code
  end

  def generate_staff_code
    usage_limit = params[:usage_limit].to_i
    school_id = Current.user.school.id

    if usage_limit > 0
      codes = Principal.generate_enrollment_code('staff')
      EnrollmentCode.create!(
        hashed_code: codes[:hashed_code],
        account_type: 'staff',
        school_id: school_id,
        usage_count: 0,
        usage_limit: usage_limit
      )
      flash[:notice] = "Staff Code Generated: #{codes[:raw_code]}"
    else
      flash[:alert] = 'Invalid number of accounts required.'
    end

    redirect_to generate_code_principal_path
  end

  def generate_student_code
    usage_limit = params[:usage_limit].to_i
    school_id = Current.user.school.id

    if usage_limit > 0
      codes = Principal.generate_enrollment_code('student')
      EnrollmentCode.create!(
        hashed_code: codes[:hashed_code],
        account_type: 'student',
        school_id: school_id,
        usage_count: 0,
        usage_limit: usage_limit
      )
      flash[:notice] = "Student Code Generated: #{codes[:raw_code]}"
    else
      flash[:alert] = 'Invalid number of accounts required.'
    end

    redirect_to generate_code_principal_path
  end

  def dashboard
    @principal_details = Current.user
    @school_details = Current.user.school
    @student_count = @school_details.students.count
    @attendance_count = Attendance.where(school: @school_details).count
    @last_checkin = Attendance.where(school: @school_details).order(created_at: :desc).first&.created_at

    @attending_students_count = Attendance.where(timestamp: Date.today.all_day).select(:student_id).distinct.count
    @weekly_attendance_data = {
      dates: (6.days.ago.to_date..Date.today).map { |date| date.strftime('%a') },
      counts:
        (6.days.ago.to_date..Date.today).map do |date|
          Attendance.where(timestamp: date.all_day).select(:student_id).distinct.count
        end
    }

    @q = @school_details.students.ransack(params[:q])
  end

  def new
    @principal = Principal.new
  end

  def create
    @principal = Principal.new(principal_params)
    if @principal.save
      start_new_session_for(@principal)
      redirect_to subscriptions_path, notice: 'Principal was successfully created.'
    else
      render :new
    end
  end

  def generate_report
    # Fetch the principal using the ID from the params
    @principal_details = Current.user

    # Fetch the associated school details
    @school_details = Current.user.school

    # Calculate the required statistics
    @student_count = @school_details.students.count
    @attendance_count = Attendance.where(school: @school_details).count
    @last_checkin = Attendance.where(school: @school_details).order(created_at: :desc).first&.created_at

    # Generate the PDF
    pdf = Prawn::Document.new
    pdf.text 'Principal Report', size: 24, style: :bold
    pdf.move_down 20

    pdf.text 'Principal Details', size: 18, style: :bold
    pdf.text "Name: #{@principal_details.name}"
    pdf.text "ID: #{@principal_details.id}"
    pdf.move_down 10

    pdf.text 'School Details', size: 18, style: :bold
    pdf.text "Name: #{@school_details.name}"
    pdf.text "Address: #{@school_details.address}"
    pdf.text "Country: #{@school_details.country}"
    pdf.move_down 10

    pdf.text 'Attendance Statistics', size: 18, style: :bold
    pdf.text "Total Students: #{@student_count}"
    pdf.text "Total Check-ins: #{@attendance_count}"
    pdf.move_down 10

    pdf.text 'Student Attendance Records', size: 18, style: :bold
    data =
      [['Name', 'Attendance Count']] +
        @school_details.students.map { |student| [student.name, Attendance.where(student: student).count] }
    pdf.table(data, header: true, row_colors: %w[F0F0F0 FFFFFF])

    send_data pdf.render, filename: 'principal_report.pdf', type: 'application/pdf', disposition: 'inline'
  end

  private

  def principal_params
    params.require(:principal).permit(
      :email_address,
      :password,
      :password_confirmation,
      :name,
      :phone_number,
      :school_id
    )
  end
end
