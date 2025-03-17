class HomeController < ApplicationController
  def index
    redirect_to_dashboard
  end

  private

  def redirect_to_dashboard
    if Current.principal?
      redirect_to principal_dashboard_path
    elsif Current.student?
      redirect_to student_dashboard_path
    elsif Current.staff?
      redirect_to staff_dashboard_path
    else
      redirect_to root_path, alert: 'Unauthorized access'
    end
  end
end
