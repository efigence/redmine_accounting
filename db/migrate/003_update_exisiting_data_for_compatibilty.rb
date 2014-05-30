class UpdateExisitngDataForCompatibility < ActiveRecord::Migration
  def up
    ###### run this to keep your data from version 0.0.1 ######
    ###########################################################
    if ProjectVersion.any?
      role_id = Setting.plugin_redmine_accounting['role_id']
      custom_id = Setting.plugin_redmine_accounting['custom_field']

      return if role_id.blank? && custom_id.blank?

      ProjectVersion.all.each do |v|
        v.user_ids = { role_id => v.user_ids } if role_id
        v.custom_field = { custom_id => v.custom_field } if custom_id
        v.save!
      end
    end
  end
end
