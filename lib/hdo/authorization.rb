module Hdo
  module Authorization
    def self.included(base)
      base.send :include, Pundit
      base.send :rescue_from, Pundit::NotAuthorizedError, with: :policy_not_allowed
    end

    def policy_not_allowed
      session[:return_to] ||= request.referer
      redirect_to session[:return_to], alert: t('app.errors.unauthorized')
    end

  end
end