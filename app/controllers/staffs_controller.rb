class StaffsController < ApplicationController
  def dashboard
  end

  def generate_code
  end

  def create_code
    usage_limit = params[:usage_limit].to_i
    school_id = Current.session.staff.school.id

    if usage_limit > 0
      codes = Staff.generate_enrollment_code('student')
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

    redirect_to staffs_generate_code_path
  end
end
