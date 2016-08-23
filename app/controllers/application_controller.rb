class ApplicationController < ActionController::Base
  protect_from_forgery
  around_filter :catch_not_found
  before_filter :authenticate_user!
  before_filter :update_last_request_stats
  helper_method :current_ability
  #
  # After Sign out, redirect to the root path (Login screen, might change later on)
  #
  def after_sign_out_path_for(resource_or_scope)
  	root_path
  end

  #
  # After sign in, redirect to root path (Dashboard)
  #
  def after_sign_in_path_for(resource)
    root_path
  end

  protected

  def require_allow_import
    require_user_type :importer?
  end

  def require_courier
    require_user_type :courier?
  end

  def require_admin
    require_user_type :admin?
  end

  def require_internal
    require_user_type :internal?
  end

  def require_write_access
    require_user_type :write_access?
  end

  # Cancan backward compatility
  def current_ability
    current_user
  end

  private

  def require_user_type(meth)
    redirect_to(root_path, alert: 'You do not have permission to access that page') unless current_user && current_user.send(meth)
  end

  #
  # If the record of any model has not be found, it will redirect to dashboard and yield an error message
  #
  def catch_not_found
    yield

    rescue ActiveRecord::RecordNotFound
      redirect_to root_url, :flash => { :error => "Record not found." }
  end

  def update_last_request_stats
    if user_signed_in?
      current_user.update_attributes(:last_request_at => Time.now, :last_request => request.fullpath.to_s[0..254])

      @online_users = User.accessible_by(current_ability).recently_signed_in
      @online_users = @online_users.reject {|u| u.id == current_user.id }
    end
  end
end
