require_dependency 'project'

module RedmineAccounting
  module Patches
    module ProjectPatch
      def self.included(base)
        base.class_eval do
          unloadable
          base.send(:include, InstanceMethods)
          has_many :project_versions
          after_save :create_project_version, :if => Proc.new { |p| p.status != 5 }
        end
      end
      module InstanceMethods
        def create_project_version
          attrs = {
            :name => name,
            :status => status,
            :project_id => id,
            :user_ids => observed_user_ids,
            :custom_field => observed_custom_value,
            :time_entry_id => last_time_entry_id
          }
          version = project_versions.build(attrs)
          return if version.same_as_previous?
          version.save
        end

        def last_time_entry_id
          TimeEntry.where(project_id: id).last.try(:id)
        end

        def observed_custom_value
          custom_id = Setting.plugin_redmine_accounting['custom_field']
          return nil if custom_id.blank?
          custom_values.where(custom_field_id: custom_id.to_i).first.try(:value)
        end

        def observed_user_ids
          members.select(:user_id).joins(:member_roles).
            where(:member_roles => { :role_id => Setting.plugin_redmine_accounting['role_id'].to_i }).map(&:user_id)
        end

        private :last_time_entry_id, :observed_custom_value, :observed_user_ids

      end
    end
  end
end
