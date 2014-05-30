require 'redmine'

Redmine::Plugin.register :redmine_accounting do
  name 'Redmine Accounting plugin'
  author 'Jacek Grzybowski'
  description 'Plugin for accounting'
  version '0.0.1'
  url 'https://github.com/efigence/redmine_accounting'
  author_url 'http://www.efigence.com/'

  menu :top_menu, :accounting,
    { :controller => 'accounting', :action => 'index' },
    :caption => 'Accounting',
    :if => proc {
     User.current.admin? ||
     !(User.current.groups.pluck(:id).map(&:to_s) & (Setting.plugin_redmine_accounting['groups'] || [])).blank?
    }

  settings :default => {
    'role_ids' => [],
    'custom_field_ids' => [],
    'groups' => []
  }, :partial => 'settings/accounting_settings'
end

ActionDispatch::Callbacks.to_prepare do
  Project.send(:include, RedmineAccounting::Patches::ProjectPatch)
  MemberRole.send(:include, RedmineAccounting::Patches::MemberRolePatch)
  ProjectsController.send(:include, RedmineAccounting::Patches::ProjectsControllerPatch)
end
