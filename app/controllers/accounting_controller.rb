class AccountingController < ApplicationController
  unloadable

  before_filter :permitted?
  before_filter :configurable_fields

  def index
    date = params.try(:[], :date_lookup).try(:to_time)

    @versions = ProjectVersion.scoped.includes(:project)
    @versions = @versions.where(project_id: params[:project_id]) unless params[:project_id].blank? || params[:project_id] == 'all'
    @versions = @versions.where(created_at: date..(date+1.day)) if date

    if !params[:change_type].blank?
      ids = @versions.select! {|v| !(v.changed_attrs.keys & params[:change_type].map(&:to_sym)).blank?}.try(:map) {|v| v.id}
      @versions = ProjectVersion.where(id: ids)
    end

    @paginate, @versions = paginate @versions, :per_page => 15
    @changes = @versions.map(&:changed_attrs)
  end

  private

  def configurable_fields
    @role_name = get_role_name
    @custom_name = get_custom_name
    @selectable_statuses = [%w(name name), %w(status status)]
    @selectable_statuses << [@role_name.downcase, "user_ids"] if @role_name
    @selectable_statuses << [@custom_name.downcase, "custom_field"] if @custom_name
  end

  def get_custom_name
    custom_field_id = Setting.plugin_redmine_accounting['custom_field']
    !custom_field_id.blank? ? CustomField.select(:name).where(id: custom_field_id).first.try(:name) : nil
  end

  def get_role_name
    role_id = Setting.plugin_redmine_accounting['role_id']
    role = Role.select(:name).where(id: role_id).first if !role_id.blank?
    role ? role.read_attribute(:name) + 's' : nil
  end

  def permitted?
    deny_access unless User.current.admin? || has_access?
  end

  def has_access?
    !(user_ids & groups_with_access).blank?
  end

  def user_ids
    User.current.groups.pluck(:id).map(&:to_s)
  end

  def groups_with_access
    Setting.plugin_redmine_accounting['groups'] || []
  end
end
