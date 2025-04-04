module Authorization
  extend ActiveSupport::Concern

  included { rescue_from NotAuthorized, with: :user_not_authorized }

  class NotAuthorized < StandardError
  end

  private

  def authorize_principal!
    raise NotAuthorized unless Current.principal?
  end

  def authorize_staff!
    raise NotAuthorized unless Current.staff?
  end

  def authorize_student!
    raise NotAuthorized unless Current.student?
  end

  def authorize_system_admin!
    raise NotAuthorized unless Current.system_admin?
  end

  def authorize_school_staff!
    raise NotAuthorized unless Current.principal? || Current.staff?
  end

  def user_not_authorized
    flash[:alert] = 'You are not authorized to perform this action.'
    redirect_to after_authentication_url
  end
end
