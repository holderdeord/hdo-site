module Hdo
  module BasicAuth

    def self.ok?(user, pass)
      !!users.find { |u, p| u == user && p == pass  }
    end

    def self.users
      @users ||= AppConfig.basic_auth_users.to_s.split(',').map { |e| e.split(':') }
    end

  end
end
