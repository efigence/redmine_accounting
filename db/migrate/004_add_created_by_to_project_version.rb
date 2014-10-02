class AddCreatedByToProjectVersion < ActiveRecord::Migration
  def change
    add_column :project_versions, :created_by, :integer
  end
end
