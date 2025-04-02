class ApplicationController < ActionController::Base
  include Authentication

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # allow_browser versions: :modern
  before_action :set_locale
  before_action :set_timezone

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def default_url_options
    { locale: I18n.locale }
  end

  def set_timezone
    if authenticated? && current_school&.timezone.present?
      Time.zone = current_school.timezone
    else
      Time.zone = 'Asia/Bangkok'
    end
  end
end

module SchoolScopable
  extend ActiveSupport::Concern

  private

  def scope_to_school(relation)
    relation.where(school_id: current_school.id)
  end
end
