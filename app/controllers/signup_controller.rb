class SignupController < ApplicationController
  allow_unauthenticated_access only: %i[new create create_principal new_principal select_plan]
  skip_before_action :require_authentication, only: %i[new_principal create_principal new select_plan]
  protect_from_forgery with: :exception

  def select_plan
    plan = params[:plan]
    amount = params[:amount]

    redirect_to new_principal_signup_path(plan: plan, amount: amount)
  end
  def new
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
        redirect_to student_dashboard_path, notice: 'Student account created successfully.'
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
        redirect_to staff_dashboard_path, notice: 'Staff account created successfully.'
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
    Rails.logger.debug "Creating principal with params: #{params.inspect}"
    plan = session[:plan]
    amount = session[:amount]

    # The session keys should match what ChargeController is storing
    principal_params = session[:principal_params]
    school_params = session[:school_params]

    if principal_params.nil? || school_params.nil?
      flash[:alert] = 'Missing required information for principal signup'
      redirect_to new_principal_signup_path
      return
    end

    @principal = Principal.new(principal_params)
    @principal.build_school(school_params)

    if @principal.save
      # Set the school's subscription status and type
      @principal.school.update(subscription_status: plan == 'free' ? 'free_trial' : 'active', subscription_type: plan)

      if session[:card_details].present?
        Rails.logger.debug "Card details found in session: #{session[:card_details].inspect}"

        # Get the card details from the session
        card_details = session[:card_details]

        if @principal.school.respond_to?(:payment_histories)
          # Create a new payment history record
          payment_history =
            @principal.school.payment_histories.new(
              amount: amount,
              payment_date: Time.current,
              payment_method: 'credit_card',
              # Use the transaction_id directly from card_details
              transaction_id: card_details['transaction_id'] || card_details[:transaction_id],
              status: 'successful',
              # Store the card details
              card_last_digits: card_details['last_digits'] || card_details[:last_digits],
              card_type: card_details['brand'] || card_details[:brand],
              subscription_plan: plan
            )

          if payment_history.save
            Rails.logger.info "Payment history created successfully: #{payment_history.id}"
          else
            Rails.logger.error "Failed to create payment history: #{payment_history.errors.full_messages.join(', ')}"
          end
        else
          Rails.logger.warn "School model doesn't have payment_histories association"
        end
      end

      # Start session for the new principal
      start_new_session_for(@principal)

      # Clean up session data
      session.delete(:principal_params)
      session.delete(:school_params)
      session.delete(:plan)
      session.delete(:amount)
      session.delete(:card_details)

      flash[:notice] = t('signup.principal.success_message', default: 'Your account has been created successfully!')
      redirect_to principal_dashboard_path
    else
      flash[:alert] = @principal.errors.full_messages.join(', ')
      redirect_to new_principal_signup_path
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
