class PrincipalsController < ApplicationController
  before_action :require_principal

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

  def settings
    @school = Current.user.school
  end

  # app/controllers/principals_controller.rb
  def update_settings
    @school = Current.user.school

    # Process custom theme if present
    if params[:school][:custom_theme].present?
      custom_theme = params[:school][:custom_theme]

      # If it contains @plugin or name:, extract just the CSS variables
      if custom_theme.include?('@plugin') || custom_theme.include?('name:')
        css_var_lines = custom_theme.split("\n").select { |line| line.strip.start_with?('--') }.join("\n")

        params[:school][:custom_theme] = css_var_lines if css_var_lines.present?
      end
    end

    if @school.update(school_settings_params)
      flash[:notice] = t('principals.settings.update_success')
      redirect_to principal_settings_path(refresh: true)
    else
      render :settings, status: :unprocessable_entity
    end
  end

  private

  def require_principal
    unless Current.principal?
      flash[:alert] = t('controllers.access_denied')
      redirect_to root_path
    end
  end

  def school_settings_params
    params.require(:school).permit(:timezone, :theme, :custom_theme)
  end

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
