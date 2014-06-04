class SessionsController < Devise::SessionsController
  include Hdo::DeviseControllerHelper

  def create
    setup_params_for_hdo_resource
    self.resource = warden.authenticate!(auth_options)
    set_flash_message(:notice, :signed_in) if is_navigational_format?
    sign_in(hdo_resource_name, resource)
    respond_with resource, :location => after_sign_in_path_for(resource)
  end
end
