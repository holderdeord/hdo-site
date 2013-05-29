module Hdo
  module DeviseControllerHelper
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

    def hdo_resource_class
      hdo_resource_name.to_s.classify.constantize
    end

    def setup_params_for_hdo_resource
      params[hdo_resource_name] = params.delete(resource_name)
    end
  end
end