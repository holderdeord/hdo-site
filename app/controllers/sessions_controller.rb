class SessionsController < Devise::SessionsController
  include Hdo::DeviseControllerHelper
  hdo_force_ssl
  before_filter :enforce_devise_user_scope, only: :new

  def create
    setup_params_for_hdo_resource
    self.resource = warden.authenticate!(auth_options)
    set_flash_message(:notice, :signed_in) if is_navigational_format?
    sign_in(hdo_resource_name, resource)
    respond_with resource, :location => after_sign_in_path_for(resource)
  end

  private

  def enforce_devise_user_scope
    flash.keep
    redirect_to new_user_session_path unless request.path == new_user_session_path
  end
end
