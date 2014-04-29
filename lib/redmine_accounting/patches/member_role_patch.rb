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
          member.project.create_project_version
        end
        def observed_role
          Setting.plugin_redmine_accounting['role_id'].to_i
        end
        def is_observed
          observed_role == role_id
        end
        private :observed_role, :is_observed
      end
    end
  end
end
