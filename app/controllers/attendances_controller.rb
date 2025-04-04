class AttendancesController < ApplicationController
  include SchoolScopable
  before_action :authorize_school_staff!
  before_action :set_attendance, only: %i[show edit update destroy]
  include Pagy::Backend

  # GET /attendances or /attendances.json
  #
  def index
    # Fix the query to work with STI by using the users table with type='Student'
    @q =
      scope_to_school(Attendance)
        .includes(:student)
        .where(users: { type: 'Student', discarded_at: nil })
        .ransack(params[:q])
    @pagy, @attendances = pagy(@q.result)
    respond_to do |format|
      format.html
      format.js { render partial: 'attendances/table', locals: { attendances: @attendances, q: @q }, layout: false }
    end
  end

  # GET /attendances/1 or /attendances/1.json
  def show
    # We already have get the attendance record in the before_action
  end

  # GET /attendances/new
  def new
    # Update to use STI for students
    @q = scope_to_school(User).where(type: 'Student').ransack(params[:q])
    @students = @q.result(distinct: true)
    @attendances = scope_to_school(Attendance).order(timestamp: :desc).limit(20).includes(:student)
    respond_to do |format|
      format.html # For normal page loads
      format.turbo_stream # For Turbo-powered live updates
    end
  end

  # GET /attendances/1/edit
  def edit
    # We can't edit attendance records
  end

  # POST /attendances or /attendances.json
  def create
    p =
      params.permit(:student_id).merge(user_id: Current.user.id, timestamp: Time.zone.now, school_id: current_school.id)
    @attendance = Attendance.new(p)
    @attendance.save!
    respond_to do |format|
      format.html { redirect_to new_attendance_path(request.parameters) } # For normal page loads
      format.turbo_stream { redirect_to new_attendance_path(request.parameters) } # For Turbo-powered live updates
      # console log the recorded uid
      logger.info("Recorded attendance for student with uid: #{p[:student_id]}")
    end
  end

  # POST /attendances/qr_attendance
  def qr_attendance
    student = User.find_by(uid: params[:attendance][:student_uid], type: 'Student')
    # log the student_uid
    logger.info("Student UID: #{params[:attendance][:student_uid]}")

    if student
      if student.school_id == current_school.id
        @attendance =
          student.attendances.new(user_id: Current.user.id, timestamp: Time.zone.now, school_id: current_school.id)
        if @attendance.save
          render json: {
                   status: 'success',
                   message: 'Attendance recorded',
                   student_name: student.name,
                   timestamp: @attendance.timestamp
                 },
                 status: :created
        else
          render json: {
                   status: 'error',
                   message: @attendance.errors.full_messages.join(', ')
                 },
                 status: :unprocessable_entity
        end
      else
        render json: { status: 'error', message: 'Student belongs to a different school' }, status: :forbidden
      end
    else
      render json: { status: 'error', message: 'Student not found' }, status: :not_found
    end
  end

  # PATCH/PUT /attendances/1 or /attendances/1.json
  def update
    respond_to do |format|
      if @attendance.update(attendance_params)
        format.html { redirect_to @attendance, notice: 'Attendance was successfully updated.' }
        format.json { render :show, status: :ok, location: @attendance }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @attendance.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /attendances/1 or /attendances/1.json
  def destroy
    @attendance.destroy!

    respond_to do |format|
      format.html { redirect_to attendances_path, status: :see_other, notice: 'Attendance was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_attendance
    @attendance = Attendance.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def attendance_params
    params
      .require(:attendance)
      .permit(:student_id, :timestamp)
      .merge(user_id: Current.user.id, school_id: current_school.id)
  end
end
