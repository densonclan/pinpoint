module PermissionsHelper

  def can?(action, subject)

    return true if current_user.admin? # admins have full access to everything
    return true if action == :read || action == :show || action == :export # anyone can read or export things

    return document_permission(action, subject) if subject.class == Document

    subject = subject.class if subject.class.superclass == ActiveRecord::Base

    return false if subject == User # only admins have access to users

    if action == :create || action == :update || action == :import
      return !current_user.read_only?
    end


    raise "Unhandled subject #{subject} or action #{action}"
  end

  def document_permission(action, document)
    return true if current_user.id == document.user_id && !current_user.read_only?
    return true if action == :read && current_user.client_id == document.user.client_id
    return false
  end
end