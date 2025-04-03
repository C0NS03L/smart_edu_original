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

    hashed_code = Digest::SHA256.hexdigest(@enrollment_code)
    code_object = EnrollmentCode.find_by(hashed_code: hashed_code)

    if code_object.nil?
      flash[:alert] = 'Invalid enrollment code.'
      render :new, status: :unprocessable_entity
      return
    end

    unless code_object.can_be_used?
      flash[:alert] = 'Enrollment code has reached its usage limit.'
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
          uid: SecureRandom.uuid
        )

      if student.save
        code_object.increment_usage_count!
        start_new_session_for(student)
        redirect_to student_dashboard_path, notice: 'Student account created successfully.'
      else
        flash[:alert] = 'Failed to create student account.'
        render :new, status: :unprocessable_entity
      end
    when 'staff'
      staff =
        Staff.new(
          email_address: params[:email_address],
          name: params[:name],
          password: user_password,
          school_id: school_id,
          uid: SecureRandom.uuid
        )

      if staff.save
        code_object.increment_usage_count!
        start_new_session_for(staff)
        redirect_to staff_dashboard_path, notice: 'Staff account created successfully.'
      else
        flash[:alert] = 'Failed to create staff account.'
        render :new, status: :unprocessable_entity
      end
    else
      flash[:alert] = 'Invalid account type.'
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

      # Get payment details
      plan = params[:plan]
      amount = params[:amount].to_i
      omise_token = params[:omiseToken]

      # Process payment
      if plan == 'free_trial' || amount == 0
        # Handle free trial
        @principal.school.set_plan_limits('free_trial')
        flash[:notice] = 'Your free trial has been activated!'
        redirect_to principal_dashboard_path
      else
        # Process payment with Omise
        begin
          Omise.api_key = 'skey_test_62unknnkqf46swrwxyn'

          charge =
            Omise::Charge.create(
              { amount: amount, currency: 'USD', card: omise_token, description: "Payment for #{plan} plan" }
            )

          if charge.paid
            # Set plan limits based on plan
            tier =
              case plan
              when 'standard'
                '500_students'
              when 'premium'
                '1000_students'
              else
                'free_trial'
              end

            @principal.school.set_plan_limits(tier)

            # Record payment details
            card_details = {
              last_digits: charge.card ? charge.card.last_digits : nil,
              brand: charge.card ? charge.card.brand : nil
            }

            @principal.school.record_payment(
              amount / 100.0,
              'credit_card',
              charge.id,
              card_details[:last_digits],
              card_details[:brand]
            )

            flash[:notice] = 'Your account has been created successfully!'
            redirect_to principal_dashboard_path
          else
            flash[:alert] = "Payment failed: #{charge.failure_message || 'Unknown error'}"
            render :new_principal, status: :unprocessable_entity
          end
        rescue => e
          Rails.logger.error("Payment error: #{e.message}")
          flash[:alert] = 'Payment system error: Please try again later'
          render :new_principal, status: :unprocessable_entity
        end
      end
    else
      render :new_principal, status: :unprocessable_entity
    end
  end

  private

  def process_payment(school, plan, amount, omise_token)
    if plan == 'free_trial' || amount == 0
      # Handle free trial
      school.set_plan_limits('free_trial')
      flash[:notice] = 'Your free trial has been activated!'
      redirect_to principal_dashboard_path
    else
      # Process payment with Omise
      begin
        Omise.api_key = 'skey_test_62unknnkqf46swrwxyn'

        charge =
          Omise::Charge.create(
            { amount: amount, currency: 'USD', card: omise_token, description: "Payment for #{plan} plan" }
          )

        if charge.paid
          # Set plan limits based on the tier
          tier =
            case plan
            when 'standard'
              '500_students'
            when 'premium'
              '1000_students'
            else
              'free_trial'
            end

          school.set_plan_limits(tier)

          # Record payment details
          card_details = {
            last_digits: charge.card ? charge.card.last_digits : nil,
            brand: charge.card ? charge.card.brand : nil
          }

          school.record_payment(
            amount / 100.0,
            'credit_card',
            charge.id,
            card_details[:last_digits],
            card_details[:brand]
          )

          flash[:notice] = 'Your account has been created successfully!'
          redirect_to principal_dashboard_path
        else
          flash[:alert] = "Payment failed: #{charge.failure_message || 'Unknown error'}"
          render :new_principal, status: :unprocessable_entity
        end
      rescue => e
        Rails.logger.error("Payment error: #{e.message}")
        flash[:alert] = 'Payment system error: Please try again later'
        render :new_principal, status: :unprocessable_entity
      end
    end
  end

  def user_params
    params.require(:user).permit(:email_address, :password, :password_confirmation, :school_id)
  end

  def student_params
    params.require(:student).permit(:name, :school_id, :email_address, :password, :password_confirmation, :uid)
  end

  def staff_params
    params.require(:staff).permit(:name, :school_id, :email_address, :password, :password_confirmation, :uid)
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
