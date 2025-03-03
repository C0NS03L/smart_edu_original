class SignupController < ApplicationController
  allow_unauthenticated_access only: %i[new create set_role choose_role new_principal create_principal]

  def new
    @role = params[:role] || ''
    @user = User.new
  end

  def create
    @role = params[:user][:role] || ''
    @name = params[:user][:name] || ''
    @enrollment_code = params[:user][:enrollment_code] || ''
    user_password = params[:user][:password]

    # The :role parameter is not permitted in the User model.
    # This line removes it from params to avoid errors when doing User.new.
    params[:user].delete(:role)
    params[:user].delete(:name)
    params[:user].delete(:enrollment_code)

    hashed_code = Digest::SHA256.hexdigest(@enrollment_code)
    puts hashed_code
    code_object = EnrollmentCode.find_by(hashed_code: hashed_code)

    if code_object.nil?
      flash[:alert] = 'Invalid enrollment code.'
      render :new, status: :unprocessable_entity
      return
    end

    school_id = code_object.school_id

    # Sanity check
    puts "Role: #{@role}"
    puts "Code: #{@enrollment_code} Hashed: #{hashed_code}"
    puts "School ID: #{school_id}"

    # TODO: Make sure if one model is invalid, the other is not created
    # TODO: Make sure the user is not created if the student/staff is not created
    # TODO: Make sure any errors are properly displayed on the right page
    # (errors rn appear on sign in page for some reason)
    # Create User
    @user = User.new(user_params)
    if @user.save
      start_new_session_for(@user)

      case @role
      when 'student'
        student =
          Student.new(
            email_address: @user.email_address,
            name: @name,
            user_id: @user.id,
            password: user_password,
            school_id: school_id
          )
        if student.save
          redirect_to after_authentication_url
        else
          puts student.errors.full_messages # Debugging information
          flash[:alert] = student.errors.full_messages.to_sentence
          render :new, status: :unprocessable_entity
        end
      when 'staff'
        staff =
          Staff.new(
            email_address: @user.email_address,
            name: @name,
            user_id: @user.id,
            password: user_password,
            school_id: school_id
          )
        if staff.save
          redirect_to after_authentication_url
        else
          puts staff.errors.full_messages # Debugging information
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

  def choose_role
  end

  def set_role
    @role = params[:role] || ''
    case @role
    when 'student'
      redirect_to new_signup_path(role: @role)
    when 'staff'
      redirect_to new_signup_path(role: @role)
    when 'principal'
      redirect_to new_principal_signup_path(role: @role)
    else
      redirect_to choose_role_path, notice: 'Invalid role'
    end
  end

  def new_principal
    @principal = Principal.new
  end

  def create_principal
    @principal = Principal.new(principal_params)
    if @principal.save
      start_new_session_for(@principal)
      redirect_to after_authentication_url
    else
      render :new_principal
    end
  end

  private

  def user_params
    params.require(:user).permit(:email_address, :password, :password_confirmation)
  end

  def student_params
    params.require(:student).permit(:name, :school_id, :email_address, :password, :password_confirmation)
  end

  def staff_params
    params.require(:staff).permit(:name, :school_id, :email_address, :password, :password_confirmation)
  end

  def principal_params
    params.require(:principal).permit(
      :school_id,
      :name,
      :email_address,
      :phone_number,
      :password,
      :password_confirmation
    )
  end
end
