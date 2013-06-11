class PasswordsController < Devise::PasswordsController
  include Hdo::DeviseControllerHelper
  hdo_force_ssl

  def create
    self.resource = hdo_resource_class.send_reset_password_instructions(resource_params)

    if successfully_sent?(resource)
      respond_with({}, :location => after_sending_reset_password_instructions_path_for(hdo_resource_name))
    else
      respond_with(resource)
    end
  end
end
