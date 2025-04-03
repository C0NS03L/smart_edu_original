class ApplicationController < ActionController::Base
  include Authentication

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # allow_browser versions: :modern
  before_action :set_locale

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def default_url_options
    { locale: I18n.locale }
  end

  def current_principal
    Current.user if Current.user.is_a?(Principal)
  end
  helper_method :current_principal
end

module SchoolScopable
  extend ActiveSupport::Concern

  private

  def scope_to_school(relation)
    relation.where(school_id: current_school.id)
  end
end
