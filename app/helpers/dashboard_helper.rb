module DashboardHelper

  def dashboard_assigned_tasks
    @assigned_tasks ||= Task.for_user_or_department(current_user).unarchived.for_dashboard
  end

  def my_dashboard_tasks
    @tasks ||= current_user.tasks.unarchived.for_dashboard
  end

  def my_messages
    @messages ||= current_user.received_messages.for_dashboard
  end

  def my_recent_activity
    @my_recent_activity ||= (current_user.internal? ? Version.scoped : Version.where(whodunnit: whodunnit_user_ids)).order('id DESC').limit(25)
  end

  def whodunnit_user_ids
    current_user.client ? current_user.client.users.pluck(:id).map{|i|i.to_s} : current_user.id.to_s
  end

  def version_type(version)
    label = "#{version.item_type} ##{version.item_id}"
    return link_to(label, order_path(version.item_id)) if version.item_type == "Order"
    return link_to(label, store_path(version.item_id)) if version.item_type == "Store"
    return link_to(label, address_path(version.item_id)) if version.item_type == "Address"
    return link_to(label, comment_path(version.item_id)) if version.item_type == "Comment"
    return link_to(label, distribution_path(version.item_id)) if version.item_type == "Distribution"
    return link_to(label, task_path(version.item_id)) if version.item_type == "Task"
    return link_to(label, edit_period_path(version.item_id)) if version.item_type == "Period"
    return link_to(label, edit_document_path(version.item_id)) if version.item_type == "Document"
    label
  end

  def version_user_name(version)
    all_user_names[version.whodunnit.to_i]
  end

  def all_user_names
    @all_user_names ||= lookup_all_users
  end

  def lookup_all_users
    hsh = {}
    User.all.each {|u| hsh[u.id] = u.name }
    hsh
  end

  def current_periods
    @current_periods ||= Period.accessible_by(current_user).all_current
  end

  def dashboard_order_count
    @order_count ||= Order.accessible_by(current_user).for_current_period.count.to_f
  end

  def dashboard_awaiting_print
    return 0 unless dashboard_order_count > 0
    Order.accessible_by(current_user).for_current_period.awaiting_print.count / dashboard_order_count
  end

  def dashboard_in_print
    return 0 unless dashboard_order_count > 0
    Order.accessible_by(current_user).for_current_period.in_print.count / dashboard_order_count
  end

  def dashboard_dispatched
    return 0 unless dashboard_order_count > 0
    Order.accessible_by(current_user).for_current_period.dispatched.count / dashboard_order_count
  end

  def dashboard_completed
    return 0 unless dashboard_order_count > 0
    Order.accessible_by(current_user).for_current_period.completed.count / dashboard_order_count
  end
end