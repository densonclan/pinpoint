module UserHelper

  def user_type_options
    [['Administrator', User::ADMIN], ['Distribution', User::DISTRIBUTION], ['Client', User::CLIENT], ['Read Only', User::READ_ONLY], ['Courier', User::COURIER]]
  end

  def accessible_users
    User.accessible_by(current_ability).ordered
  end  
end