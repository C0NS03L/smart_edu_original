class StudentsController < ApplicationController
  before_action :set_student, only: %i[show edit update destroy]
  before_action :set_student, only: %i[show edit update destroy]
  attr_reader :student # helps with testing
  attr_reader :students
  include Pagy::Backend
  # GET /students or /students.json
  def index
    @q = Student.kept.ransack(params[:q])
    @pagy, @students = pagy(@q.result(distinct: true))
    respond_to do |format|
      format.html
      format.js { render partial: 'students/table', locals: { students: @students, q: @q }, layout: false }
    end
  end

  # GET /students/1 or /students/1.json
  def show
    @student = Student.kept.find(params[:id]) # Fetch the student by ID from the database
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
    @student = Student.find(params.expect(:id))
    @student = Student.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def student_params
    params.require(:student).permit(:name)
  end
end
