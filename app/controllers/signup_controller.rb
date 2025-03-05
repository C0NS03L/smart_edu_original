class SignupController < ApplicationController
  allow_unauthenticated_access only: %i[new create create_principal]
  skip_before_action :require_authentication, only: %i[new_principal create_principal]

  def new
    @user = User.new
  end

  def create
    @enrollment_code = params[:user][:enrollment_code] || ''
    user_password = params[:user][:password]

    # Remove unnecessary parameters
    params[:user].delete(:enrollment_code)

    hashed_code = Digest::SHA256.hexdigest(@enrollment_code)
    code_object = EnrollmentCode.find_by(hashed_code: hashed_code)

    if code_object.nil?
      flash[:alert] = 'Invalid enrollment code.'
      render :new, status: :unprocessable_entity
      return
    end

    @role = code_object.role
    school_id = code_object.school_id

    @user = User.new(user_params)
    if @user.save
      start_new_session_for(@user)

      case @role
      when 'student'
        student =
          Student.new(
            email_address: @user.email_address,
            name: params[:user][:name],
            user_id: @user.id,
            password: user_password,
            school_id: school_id
          )
        if student.save
          redirect_to after_authentication_url
        else
          flash[:alert] = student.errors.full_messages.to_sentence
          render :new, status: :unprocessable_entity
        end
      when 'staff'
        staff =
          Staff.new(
            email_address: @user.email_address,
            name: params[:user][:name],
            user_id: @user.id,
            password: user_password,
            school_id: school_id
          )
        if staff.save
          redirect_to after_authentication_url
        else
          flash[:alert] = staff.errors.full_messages.to_sentence
          render :new, status: :unprocessable_entity
        end
      else
        render :new, status: :unprocessable_entity
      end
    else
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
      redirect_to after_authentication_url
    else
      Rails.logger.debug "Principal creation failed: #{@principal.errors.full_messages.to_sentence}"
      flash[:alert] = @principal.errors.full_messages.to_sentence
      render :new_principal
    end
  end

  private

  def user_params
    params.require(:user).permit(:email_address, :password, :password_confirmation)
  end

  def principal_params
    params.require(:principal).permit(
      :school_id,
      :name,
      :email_address,
      :phone_number,
      :password,
      :password_confirmation,
      school_attributes: %i[name address country]
    )
  end
end
