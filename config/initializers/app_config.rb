class AppConfig < Settingslogic
  source "#{Rails.root}/config/application.yml"
  namespace Rails.env
  load!

  # temporary helper until we migrate to new production servers
  def self.beta?
    if defined?(@beta)
      @beta
    else
      @beta = Socket.gethostname.include?('hetzner02')
    end
  end
end