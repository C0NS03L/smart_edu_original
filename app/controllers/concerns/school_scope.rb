# app/controllers/concerns/school_scope.rb
module SchoolScope
  extend ActiveSupport::Concern

  included { before_action :require_same_school }

  private

  def require_same_school
    redirect_to root_path, alert: "You don't have access to this resource" unless resource&.school == current_school
  end

  def scope_to_school(relation)
    relation.where(school: current_school)
  end
end
