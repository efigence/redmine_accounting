require_dependency 'projects_controller'

module RedmineAccounting
  module Patches
    module ProjectsControllerPatch
      def self.included(base)
        base.class_eval do
          unloadable
          base.send(:include, InstanceMethods)
          after_filter :save_parent_version, :only => [:reopen, :close, :archive]
        end
      end
      module InstanceMethods
        def save_parent_version
          @project.reload.send(:create_project_version)
        end
        private :save_parent_version
      end
    end
  end
end
