class AccountingController < ApplicationController
  unloadable

  before_filter :permitted?
  before_filter :configurable_fields

  def index
    date = params.try(:[], :date_lookup).try(:to_time)
    @selectable_statuses = [%w(name name), %w(status status), ['observed roles', 'user_ids'], ['custom fields', 'custom_field']]

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
    prepare_roles
    prepare_custom_fields
  end

  def prepare_dynamic_data(klass)
    ids = Setting.plugin_redmine_accounting["#{klass.name.underscore}_ids"]
    klass.where(id: ids).inject({}){|h, obj| h[obj.name] = obj.id.to_s; h}
  end

  def prepare_roles
    @roles ||= prepare_dynamic_data(Role)
  end

  def prepare_custom_fields
    @custom ||= prepare_dynamic_data(CustomField)
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
