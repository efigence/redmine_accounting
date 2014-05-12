module AccountingHelper
  def multi_user_link(user_ids, previous_ids)
    @same_ids, @new_ids, @deleted_ids = obtain_changes(user_ids, previous_ids)
    @str = ''
    modified_member_links(@same_ids) do
     "<strong><em>#{l('accounting.no_changes')}:</em></strong><br />"
    end
    modified_member_links(@new_ids) do
      s = "<strong><em>#{l('accounting.added')}:</em></strong><br />"
      @same_ids.blank? ? s : s.prepend("<br />")
    end
    modified_member_links(@deleted_ids) do
      s = "<strong><em>#{l('accounting.deleted')}:</em></strong><br />"
      (@same_ids.blank? && @new_ids.blank?) ? s : s.prepend("<br />")
    end
    @str.html_safe
  end

  def obtain_changes(user_ids, previous_ids)
    if previous_ids.nil?
      [user_ids, nil, nil]
    else
      [user_ids & previous_ids, user_ids - previous_ids, previous_ids - user_ids]
    end
  end

  def modified_member_links(ids)
    if !ids.blank?
      @str << yield
      @str << User.select([:id, :login, :firstname, :lastname]).where(id: ids).map do |user|
                link_to("#{user.to_s} (#{user.login})", user_path(user))
              end.join('<br />')
    end
  end

  def show_custom_changes(current, previous)
    if previous.blank?
      str = "<p class='inline'>#{@custom_name} #{l('accounting.was_added')}: <em><strong>#{current}</strong></em></p>"
    elsif current.blank? && !previous.blank?
      str = "<p class='inline'>#{@custom_name}<em><strong> #{previous} </strong></em>#{l('accounting.was_deleted')}</p>"
    else
      str = "<p class='inline'>#{@custom_name} #{l('accounting.was_changed')} <em><strong>#{previous}</strong></em>"
      str << " #{l('accounting.to')} <em><strong>#{current}</strong></em></p>"
    end
    str.html_safe
  end

  def show_name_changes(current, previous, project_id)
    str = "<p class='inline'>#{l('accounting.name_changed')} <em><strong>#{previous}</strong></em> #{l('accounting.to')} </p>"
    if project = Project.find_by_id(project_id)
      str << link_to(current, project_path(project), :style => 'display:inline;', class: 'high-light')
    else
      str << "<p class='inline'><strong><em>#{current}</em></strong></p>"
    end
    str.html_safe
  end

  def show_created_info
    "<p>#{l('accounting.project_was')} <strong><em>#{l('accounting.created')}</em><strong></p>".html_safe
  end

  def show_status_changes(current, previous)
    case
    when current == Project::STATUS_ACTIVE && previous == Project::STATUS_CLOSED
      "<p>#{l('accounting.project_was')} <strong><em>#{l('accounting.reopened')}</em><strong></p>".html_safe
    when current == Project::STATUS_CLOSED && previous == Project::STATUS_ACTIVE
      "<p>#{l('accounting.project_was')} <strong><em>#{l('accounting.closed')}</em></strong></p>".html_safe
    when current == Project::STATUS_ACTIVE && previous == Project::STATUS_ARCHIVED
      "<p>#{l('accounting.changed_state')} <strong><em>#{l('accounting.archived')}</em></strong> #{l('accounting.to')} <strong><em>#{l('accounting.reopened')}</em></strong></p>".html_safe
    when current == Project::STATUS_ARCHIVED && previous == Project::STATUS_ACTIVE
      "<p>#{l('accounting.project_was')} <strong><em>#{l('accounting.archived')}</em></strong></p>".html_safe
    end
  end

  def humanize_status(code)
    case code
    when 1 then l('accounting.open')
    when 5 then l('accounting.closed')
    when 9 then l('accounting.archived')
    end
  end

  def time_entry_data(id)
    time_entry = TimeEntry.where(id: id).first
    return nil unless time_entry
    user = time_entry.user
    time = time_entry.updated_on.strftime("%d/%m/%Y %H:%M")
    ("#{time} - " << link_to("#{user.to_s} (#{user.login})", user_path(user))).html_safe
  end

  def highlight_if_reopened(previous, current)
    "class='attr-changed'".html_safe if !previous.nil? && current == 1
  end
end
