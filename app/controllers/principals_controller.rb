class PrincipalsController < ApplicationController
  # Allow unauthenticated access to the new and create actions
  allow_unauthenticated_access only: %i[new create]

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

    @q = @school_details.students.ransack(params[:q])

    @recent_payments = Current.user.school.payment_histories.order(payment_date: :desc).limit(5) if Current.user.school
  end

  def new
    @principal = Principal.new
    @principal.build_school
  end

  def create
    @principal = Principal.new(principal_params)
    if @principal.save
      start_new_session_for(@principal)
      redirect_to subscriptions_path, notice: 'Principal account created successfully.'
    else
      render :new
    end
  end

  private

  def principal_params
    params.require(:principal).permit(
      :name,
      :email_address,
      :password,
      :password_confirmation,
      school_attributes: %i[name address]
    )
  end
end
