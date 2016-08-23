module ClientsHelper

  def clients
    Client.accessible_by(current_user).ordered
  end
  
  def client_options
    options_from_collection_for_select clients, :id, :name, params[:client]
  end
end