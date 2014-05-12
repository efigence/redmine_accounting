class ProjectVersion < ActiveRecord::Base
  unloadable

  belongs_to :project

  default_scope { order('created_at DESC') }

  serialize :user_ids
  serialize :custom_field

  def self.observed
    %w(name status user_ids custom_field)
  end

  def previous
    if persisted?
      ProjectVersion.where('id < :version_id AND project_id = :project_id',
        {:version_id => self.id, :project_id => self.project_id}).first
    else
      project.project_versions.first
    end
  end

  def first_instance?
    !previous
  end

  def changed_attrs
    prev_version = previous
    return { :status => nil } unless prev_version
    attributes.keys.select{ |k| self.class.observed.include?(k) }.
      select{ |a| prev_version[a] != send(:[], a) }.
      inject({}){ |h, key| h[key] = prev_version[key]; h }.symbolize_keys
  end

  def same_as_previous?
    last = previous
    return false unless last
    self.class.observed.each do |k|
      return false unless observed_attrs[k] == last.observed_attrs[k]
    end
    true
  end

  def observed_attrs
    @observed_attrs ||= attributes.select { |k,_| self.class.observed.include?(k) }
  end
end
