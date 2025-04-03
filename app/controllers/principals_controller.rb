class PrincipalsController < ApplicationController
  FLASH_PARTIAL = 'shared/flash'.freeze
  DELETE_ERROR_MESSAGE = 'principals.manage_codes.delete_error'.freeze

  def generate_code
  end

  def generate_staff_code
    usage_limit = params[:usage_limit].to_i
    school_id = Current.user.school.id

    if usage_limit > 0
      code = Principal.generate_enrollment_code('staff')
      EnrollmentCode.create!(
        code: code,
        account_type: 'staff',
        school_id: school_id,
        usage_count: 0,
        usage_limit: usage_limit
      )
      flash[:notice] = "Staff Code Generated: #{code}"
    else
      flash[:alert] = 'Invalid number of accounts required.'
    end

    redirect_to generate_code_principal_path
  end

  def generate_student_code
    usage_limit = params[:usage_limit].to_i
    school_id = Current.user.school.id

    if usage_limit > 0
      code = Principal.generate_enrollment_code('student')
      EnrollmentCode.create!(
        code: code,
        account_type: 'student',
        school_id: school_id,
        usage_count: 0,
        usage_limit: usage_limit
      )
      flash[:notice] = "Student Code Generated: #{code}"
    else
      flash[:alert] = 'Invalid number of accounts required.'
    end

    redirect_to generate_code_principal_path
  end

  def manage_codes
    codes = EnrollmentCode.where(school_id: Current.user.school.id)

    case params[:filter]
    when 'active'
      codes = codes.where('usage_limit IS NULL OR usage_count < usage_limit')
    when 'used_up'
      codes = codes.where('usage_limit IS NOT NULL AND usage_count >= usage_limit')
    else
      codes = codes
    end

    @enrollment_codes = codes.order(created_at: :desc)
  end

  CODE_NOT_FOUND = 'principals.manage_codes.not_found'.freeze

  def delete_code
    begin
      code = EnrollmentCode.where(school_id: Current.user.school.id).find(params[:id])

      if code.destroy
        respond_to do |format|
          format.html { redirect_to manage_codes_principal_path, notice: t('principals.manage_codes.delete_success') }
          format.turbo_stream do
            flash.now[:notice] = t('principals.manage_codes.delete_success')
            render turbo_stream: [
                     turbo_stream.remove("code-#{params[:id]}"),
                     turbo_stream.update('flash', partial: FLASH_PARTIAL)
                   ]
          end
          format.json { head :no_content }
        end
      else
        respond_to do |format|
          format.html { redirect_to manage_codes_principal_path, alert: t(DELETE_ERROR_MESSAGE) }
          format.turbo_stream do
            flash.now[:alert] = t(DELETE_ERROR_MESSAGE)
            render turbo_stream: turbo_stream.update('flash', partial: FLASH_PARTIAL)
          end
          format.json { render json: { error: t(DELETE_ERROR_MESSAGE) }, status: :unprocessable_entity }
        end
      end
    rescue ActiveRecord::RecordNotFound
      respond_to do |format|
        format.html { redirect_to manage_codes_principal_path, alert: t(CODE_NOT_FOUND) }
        format.turbo_stream do
          flash.now[:alert] = t(CODE_NOT_FOUND)
          render turbo_stream: turbo_stream.update('flash', partial: FLASH_PARTIAL)
        end
        format.json { render json: { error: t(CODE_NOT_FOUND) }, status: :not_found }
      end
    rescue => e
      Rails.logger.error("Error deleting enrollment code: #{e.message}")
      respond_to do |format|
        format.html { redirect_to manage_codes_principal_path, alert: t(DELETE_ERROR_MESSAGE) }
        format.turbo_stream do
          flash.now[:alert] = t(DELETE_ERROR_MESSAGE)
          render turbo_stream: turbo_stream.update('flash', partial: FLASH_PARTIAL)
        end
        format.json { render json: { error: e.message }, status: :internal_server_error }
      end
    end
  end

  NO_USED_CODES = 'principals.manage_codes.no_used_codes'.freeze
  DELETE_USED_ERROR = 'principals.manage_codes.delete_used_error'.freeze
  def delete_used_codes
    begin
      # Find codes that are fully used, principals can delete both student and staff codes
      codes =
        EnrollmentCode.where(school_id: Current.user.school.id).where(
          'usage_limit IS NOT NULL AND usage_count >= usage_limit'
        )

      count = codes.count

      if count == 0
        respond_to do |format|
          format.html { redirect_to manage_codes_principal_path, alert: t(NO_USED_CODES) }
          format.turbo_stream do
            flash.now[:alert] = t(NO_USED_CODES)
            render turbo_stream: turbo_stream.update('flash', partial: FLASH_PARTIAL)
          end
          format.json { render json: { message: t(NO_USED_CODES) }, status: :not_found }
        end
        return
      end

      # Use transaction to ensure all or nothing deletion
      ActiveRecord::Base.transaction do
        if codes.destroy_all
          # If successful, reload codes after deletion
          @enrollment_codes = EnrollmentCode.where(school_id: Current.user.school.id).order(created_at: :desc)

          respond_to do |format|
            format.html do
              redirect_to manage_codes_principal_path,
                          notice: t('principals.manage_codes.deleted_used_codes', count: count)
            end
            format.turbo_stream do
              flash.now[:notice] = t('principals.manage_codes.deleted_used_codes', count: count)
              render turbo_stream: [
                       turbo_stream.update('flash', partial: FLASH_PARTIAL),
                       turbo_stream.update(
                         'enrollment-codes-table',
                         partial: 'enrollment_codes_table',
                         locals: {
                           enrollment_codes: @enrollment_codes
                         }
                       )
                     ]
            end
            format.json { render json: { deleted: count }, status: :ok }
          end
        else
          # Handle unexpected failure in destroy_all (unlikely)
          raise StandardError.new('Failed to delete codes')
        end
      end
    rescue => e
      Rails.logger.error("Error deleting used enrollment codes: #{e.message}")
      respond_to do |format|
        format.html { redirect_to manage_codes_principal_path, alert: t(DELETE_USED_ERROR) }
        format.turbo_stream do
          flash.now[:alert] = t(DELETE_USED_ERROR)
          render turbo_stream: turbo_stream.update('flash', partial: FLASH_PARTIAL)
        end
        format.json { render json: { error: t(DELETE_USED_ERROR), details: e.message }, status: :internal_server_error }
      end
    end
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
