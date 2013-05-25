class SessionsController < Devise::SessionsController
  hdo_force_ssl
  before_filter :enforce_devise_user_scope, only: :new

  def create
    setup_params_for_hdo_resource
    self.resource = warden.authenticate!(auth_options)
    set_flash_message(:notice, :signed_in) if is_navigational_format?
    sign_in(hdo_resource_name, resource)
    respond_with resource, :location => after_sign_in_path_for(resource)
  end

  protected

  def auth_options
    { :scope => hdo_resource_name, :recall => "#{controller_path}#new" }
  end

  private

  def hdo_resource_name
    @resource_name ||= if User.find_by_email(params[resource_name][:email])
      :user
    else
      :representative
    end
    @resource_name
  end

  def setup_params_for_hdo_resource
    params[hdo_resource_name] = params.delete(resource_name)
  end

  def enforce_devise_user_scope
    redirect_to new_user_session_path unless request.path == new_user_session_path
  end
end
