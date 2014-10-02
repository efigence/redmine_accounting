require_dependency 'project'

module RedmineAccounting
  module Patches
    module ProjectPatch
      def self.included(base)
        base.class_eval do
          unloadable
          base.send(:include, InstanceMethods)
          has_many :project_versions
          after_save :create_project_version, :if => Proc.new { |p| p.active? }
        end
      end
      module InstanceMethods
        def create_project_version
          attrs = {
            :name => name,
            :status => status,
            :project_id => id,
            :user_ids => observed_roles,
            :custom_field => observed_custom_fields,
            :time_entry_id => last_time_entry_id
          }
          version = project_versions.build(attrs)
          return if version.same_as_previous?
          version.created_by = User.current.id if User.current
          version.save
        end

        def last_time_entry_id
          TimeEntry.where(project_id: id).last.try(:id)
        end

        def observed_roles
          observed_dynamically('role_ids') do |hash, id|
            usr_ids = members.select(:user_id).joins(:member_roles).
                        where(:member_roles => { :role_id => id }).map(&:user_id)
            hash[id] = usr_ids
          end
        end

        def observed_custom_fields
          observed_dynamically('custom_field_ids') do |hash, id|
            value = custom_values.where(custom_field_id: id).first.try(:value)
            hash[id] = value unless value.blank?
          end
        end

        def observed_dynamically(setting_key, &block)
          ids = Setting.plugin_redmine_accounting[setting_key]
          return nil if ids.blank?
          ids.inject({}) do |hash, id|
            yield(hash, id)
            hash
          end
        end

        private :create_project_version, :last_time_entry_id, :observed_roles, :observed_custom_fields
      end
    end
  end
end
