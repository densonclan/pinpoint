module BusinessManagersHelper

  def business_managers
    BusinessManager.accessible_by(current_user).ordered
  end

  def business_manager_options
    options_from_collection_for_select business_managers, :id, :name, params[:business_manager]
  end    
end