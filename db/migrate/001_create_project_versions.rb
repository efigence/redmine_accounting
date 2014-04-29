class CreateProjectVersions < ActiveRecord::Migration
  def change
    create_table :project_versions do |t|
      t.integer :project_id
      t.string :name
      t.integer :status
      t.text :user_ids
      t.text :custom_field
      t.integer :time_entry_id

      t.timestamps
    end
    add_index :project_versions, :name
  end
end
