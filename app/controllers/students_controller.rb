class StudentsController < ApplicationController
  before_action :authorize_student!, only: %i[dashboard show]
  before_action :authorize_school_staff!, except: [:dashboard]
  before_action :set_student, only: %i[show edit update destroy]
  attr_reader :student # helps with testing
  attr_reader :students
  include Pagy::Backend
  # GET /students or /students.json
  def index
    @q = Student.kept.where(school: current_school).ransack(params[:q])
    @pagy, @students = pagy(@q.result(distinct: true))
    respond_to do |format|
      format.html
      format.js { render partial: 'students/table', locals: { students: @students, q: @q }, layout: false }
    end
  end

  def dashboard
    @student_details = Current.user
    @school_details = Current.user.school
    @attendance_history = Attendance.where(student: @student_details).order(timestamp: :desc)
    @q = @school_details.students.ransack(params[:q])
  end

  # GET /students/1 or /students/1.json
  def show
    @student = Student.kept.where(school: current_school).find(params[:id])

    # Ensure students can only access their own QR code
    if current_user.is_a?(Student) && current_user.id != @student.id
      redirect_to dashboard_students_path, alert: 'You can only access your own QR code'
      return
    end

    respond_to do |format|
      format.html { render 'show' }
      format.js
      format.json { render json: @student }
    end
  end

  # GET /students/new
  def new
    @student = Student.new
  end

  # GET /students/1/edit
  def edit
  end

  def edit
  end
  # POST /students or /students.json
  def create
    @student = Student.new(student_params)

    respond_to do |format|
      if @student.save
        format.html { redirect_to @student, notice: 'Student was successfully created.' }
        format.json { render :show, status: :created, location: @student }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @student.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /students/1 or /students/1.json
  def update
    respond_to do |format|
      if @student.update(student_params)
        format.html { redirect_to @student, notice: 'Student was successfully updated.' }
        format.json { render :show, status: :ok, location: @student }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @student.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /students/1 or /students/1.json
  def destroy
    @student.discard!

    respond_to do |format|
      format.html do
        redirect_to students_path, status: :see_other, notice: "#{@student.name} was successfully removed."
      end
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_student
    @student = Student.where(school: current_school).find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def student_params
    params.require(:student).permit(:name).merge(school_id: current_school.id)
  end
end
