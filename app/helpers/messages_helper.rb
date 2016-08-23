module MessagesHelper

  def message_menu_class(action)
    action == params[:action] ? 'active' : nil
  end
end
