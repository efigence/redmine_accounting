module AccountingHelper
  def multi_user_link(user_ids, previous_ids)
    @same_ids, @new_ids, @deleted_ids = obtain_changes(user_ids, previous_ids)
    @str = ''
    modified_member_links(@same_ids) do
     "<b><i>#{l('accounting.no_changes')}:</i></b><br />"
    end
    modified_member_links(@new_ids) do
      s = "<b><i>#{l('accounting.added')}:</i></b><br />"
      @same_ids.blank? ? s : s.prepend("<br />")
    end
    modified_member_links(@deleted_ids) do
      s = "<b><i>#{l('accounting.deleted')}:</i></b><br />"
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
      str = "<p class='inline'>#{@custom_name} #{l('accounting.was_added')}: </p><p class='inline high-light'>#{current}</p>"
    elsif current.blank? && !previous.blank?
      str = "<p class='inline'>#{@custom_name} </p><p class='inline high-light'>#{previous} </p>"
      str << "<p class='inline'>#{l('accounting.was_deleted')}</p>"
    else
      str = "<p class='inline'>#{@custom_name} #{l('accounting.was_changed')} </p><p class='inline high-light'>#{previous}"
      str << "<p class='inline'> #{l('accounting.to')} </p><p class='inline high-light'>#{current}</p>"
    end
    str.html_safe
  end

  def show_name_changes(current, previous, project_id)
    str = "<p class='inline'>#{l('accounting.name_changed')} </p><p class='inline high-light'>#{previous}"
    str << "<p class='inline'> #{l('accounting.to')} </p>"
    if project = Project.find_by_id(project_id)
      str << link_to(current, project_path(project), :style => 'display:inline;', class: 'high-light')
    else
      str << "<p class='high-light'>#{current}</p>"
    end
    str.html_safe
  end

  def show_status_changes(current, previous)
    # STATUS_ACTIVE     = 1
    # STATUS_CLOSED     = 5
    # STATUS_ARCHIVED   = 9
    case
    when current == 1 && previous == 5
      "<p>#{l('accounting.project_was')} <b><i>#{l('accounting.reopened')}</i><b></p>".html_safe
    when current == 5 && previous == 1
      "<p>#{l('accounting.project_was')} <b><i>#{l('accounting.closed')}</i></b></p>".html_safe
    when current == 1 && previous == 9
      "<p>#{l('accounting.changed_state')} <b><i>#{l('accounting.archived')}</i></b> #{l('accounting.to')} <b><i>#{l('accounting.reopened')}</i></b></p>".html_safe
    when current == 9 && previous == 1
      "<p>#{l('accounting.project_was')} <b><i>#{l('accounting.archived')}</i></b></p>".html_safe
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
