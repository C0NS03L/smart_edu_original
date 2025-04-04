class SignupController < ApplicationController
  allow_unauthenticated_access only: %i[new create create_principal]
  skip_before_action :require_authentication, only: %i[new_principal create_principal]

  def new
    # @role = params[:role] || ''
    @user = User.new
    @schools = School.order(:name)
  end

  def create
    @enrollment_code = params[:enrollment_code] || ''
    user_password = params[:password]

    code_object = EnrollmentCode.find_by(code: @enrollment_code)

    if code_object.nil?
      flash.now[:alert] = 'Invalid enrollment code.'
      render :new, status: :unprocessable_entity
      return
    end

    unless code_object.can_be_used?
      flash.now[:alert] = 'Enrollment code has reached its usage limit.'
      render :new, status: :unprocessable_entity
      return
    end

    account_type = code_object.account_type
    school_id = code_object.school_id

    case account_type
    when 'student'
      student =
        Student.new(
          email_address: params[:email_address],
          name: params[:name],
          password: user_password,
          school_id: school_id,
          uid: SecureRandom.uuid,
          phone_number: params[:phone_number]
        )
      if student.save
        code_object.increment_usage_count!
        start_new_session_for(student)
        flash.now[:notice] = 'Student account created successfully.'
        redirect_to student_dashboard_path
      else
        Rails.logger.error(student.errors.full_messages)
        flash.now[:alert] = 'Failed to create student account.'
        render :new, status: :unprocessable_entity
      end
    when 'staff'
      staff =
        Staff.new(
          email_address: params[:email_address],
          name: params[:name],
          password: user_password,
          school_id: school_id,
          uid: SecureRandom.uuid,
          phone_number: params[:phone_number]
        )
      if staff.save
        code_object.increment_usage_count!
        start_new_session_for(staff)
        flash.now[:notice] = 'Staff account created successfully.'
        redirect_to staff_dashboard_path
      else
        Rails.logger.error(staff.errors.full_messages)
        flash.now[:alert] = 'Failed to create staff account.'
        render :new, status: :unprocessable_entity
      end
    else
      flash.now[:alert] = 'Invalid account type.'
      @schools = School.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def new_principal
    @principal = Principal.new
    @principal.build_school
  end

  def create_principal
    @principal = Principal.new(principal_params)
    if @principal.save
      start_new_session_for(@principal)
      redirect_to subscriptions_path, notice: 'Principal was successfully created.'
    else
      Rails.logger.debug "Principal creation failed: #{@principal.errors.full_messages.to_sentence}"
      flash.now[:alert] = @principal.errors.full_messages.to_sentence
      render :new_principal
    end
  end

  private

  def user_params
    params.require(:user).permit(:email_address, :password, :password_confirmation, :school_id)
  end

  def student_params
    params.require(:student).permit(
      :name,
      :school_id,
      :email_address,
      :password,
      :password_confirmation,
      :uid,
      :phone_number
    )
  end

  def staff_params
    params.require(:staff).permit(
      :name,
      :school_id,
      :email_address,
      :password,
      :password_confirmation,
      :uid,
      :phone_number
    )
  end

  def principal_params
    params.require(:principal).permit(
      :name,
      :email_address,
      :phone_number,
      :password,
      :password_confirmation,
      school_attributes: %i[name address country]
    )
  end
end
