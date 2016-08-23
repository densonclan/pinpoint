module AccessibleBy

  def accessible_by(user, action = 'ignored')
    user.internal? ? scoped : where("#{table_name}.client_id=?", user.client_id)
  end
end