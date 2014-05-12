class PopulateProjectVersionsWithExistingProjects < ActiveRecord::Migration
  def change
    Project.unscoped.each do |project|
      project.send(:create_project_version)
    end
  end
end
