class StaffsController < ApplicationController
  FLASH_PARTIAL = 'shared/flash'.freeze
  DELETE_ERROR_MESSAGE = 'staffs.manage_codes.delete_error'.freeze

  def dashboard
    @staff_details = Current.user
    @school_details = Current.user.school
    @student_count = @school_details.students.count
    @attendance_count = Attendance.where(school: @school_details).count
    @last_checkin = Attendance.where(school: @school_details).order(created_at: :desc).first&.created_at

    @q = @school_details.students.ransack(params[:q])
  end

  def generate_code
  end

  def create_code
    usage_limit = params[:usage_limit].to_i
    school_id = Current.user.school.id

    if usage_limit > 0
      code = Staff.generate_enrollment_code('student')
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

    redirect_to staffs_generate_code_path
  end

  def manage_codes
    codes = EnrollmentCode.where(school_id: Current.user.school.id, account_type: 'student')

    case params[:filter]
    when 'active'
      # For codes with limit, check they're not fully used. For unlimited, include all
      codes = codes.where('usage_limit IS NULL OR usage_count < usage_limit')
    when 'used_up'
      # Only show codes that have a limit and have reached it
      codes = codes.where('usage_limit IS NOT NULL AND usage_count >= usage_limit')
    else
    end

    @enrollment_codes = codes.order(created_at: :desc)
  end

  CODE_NOT_FOUND = 'staffs.manage_codes.not_found'.freeze
  def delete_code
    begin
      code = EnrollmentCode.where(school_id: Current.user.school.id, account_type: 'student', id: params[:id]).first

      if code.nil?
        respond_to do |format|
          format.html { redirect_to staffs_manage_codes_path, alert: t(CODE_NOT_FOUND) }
          format.turbo_stream do
            flash.now[:alert] = t(CODE_NOT_FOUND)
            render turbo_stream: turbo_stream.update('flash', partial: FLASH_PARTIAL)
          end
          format.json { render json: { error: t(CODE_NOT_FOUND) }, status: :not_found }
        end
        return
      end

      if code.destroy
        respond_to do |format|
          format.html { redirect_to staffs_manage_codes_path, notice: t('staffs.manage_codes.delete_success') }
          format.turbo_stream do
            flash.now[:notice] = t('staffs.manage_codes.delete_success')
            render turbo_stream: [
                     turbo_stream.remove("code-#{params[:id]}"),
                     turbo_stream.update('flash', partial: FLASH_PARTIAL)
                   ]
          end
          format.json { head :no_content }
        end
      else
        respond_to do |format|
          format.html { redirect_to staffs_manage_codes_path, alert: t(DELETE_ERROR_MESSAGE) }
          format.turbo_stream do
            flash.now[:alert] = t(DELETE_ERROR_MESSAGE)
            render turbo_stream: turbo_stream.update('flash', partial: FLASH_PARTIAL)
          end
          format.json { render json: { error: t(DELETE_ERROR_MESSAGE) }, status: :unprocessable_entity }
        end
      end
    rescue => e
      Rails.logger.error("Error deleting enrollment code: #{e.message}")
      respond_to do |format|
        format.html { redirect_to staffs_manage_codes_path, alert: t(DELETE_ERROR_MESSAGE) }
        format.turbo_stream do
          flash.now[:alert] = t(DELETE_ERROR_MESSAGE)
          render turbo_stream: turbo_stream.update('flash', partial: FLASH_PARTIAL)
        end
        format.json { render json: { error: e.message }, status: :internal_server_error }
      end
    end
  end

  NO_USED_CODES = 'staffs.manage_codes.no_used_codes'.freeze
  DELETE_USED_ERROR = 'staffs.manage_codes.delete_used_error'.freeze
  def delete_used_codes
    begin
      # Find codes that are fully used
      codes =
        EnrollmentCode.where(school_id: Current.user.school.id, account_type: 'student').where(
          'usage_limit IS NOT NULL AND usage_count >= usage_limit'
        )

      count = codes.count

      if count == 0
        respond_to do |format|
          format.html { redirect_to staffs_manage_codes_path, alert: t(NO_USED_CODES) }
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
          @enrollment_codes =
            EnrollmentCode.where(school_id: Current.user.school.id, account_type: 'student').order(created_at: :desc)

          respond_to do |format|
            format.html do
              redirect_to staffs_manage_codes_path, notice: t('staffs.manage_codes.deleted_used_codes', count: count)
            end
            format.turbo_stream do
              flash.now[:notice] = t('staffs.manage_codes.deleted_used_codes', count: count)
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
        format.html { redirect_to staffs_manage_codes_path, alert: t(DELETE_USED_ERROR) }
        format.turbo_stream do
          flash.now[:alert] = t(DELETE_USED_ERROR)
          render turbo_stream: turbo_stream.update('flash', partial: FLASH_PARTIAL)
        end
        format.json { render json: { error: t(DELETE_USED_ERROR), details: e.message }, status: :internal_server_error }
      end
    end
  end
end
