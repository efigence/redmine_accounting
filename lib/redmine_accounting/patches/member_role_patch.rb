require_dependency 'member_role'

module RedmineAccounting
  module Patches
    module MemberRolePatch
      def self.included(base)
        base.class_eval do
          unloadable
          base.send(:include, InstanceMethods)
          after_save    :save_project_version, :if => :is_observed
          after_destroy :save_project_version, :if => :is_observed
        end
      end
      module InstanceMethods
        def save_project_version
          member.project.send(:create_project_version)
        end

        def observed_role_ids
          Setting.plugin_redmine_accounting['role_ids'].map(&:to_i)
        end

        def is_observed
          observed_role_ids.include?(role_id)
        end
        private :is_observed, :observed_role_ids
      end
    end
  end
end
