class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # allow_browser versions: :modern
end

module SchoolScopable
  extend ActiveSupport::Concern

  private

  def scope_to_school(relation)
    relation.where(school_id: current_school.id)
  end
end
