module Hdo
  module Import

    shared_context :persister do
      let :log do
        Rails.logger
      end

      let :persister do
        persister = Persister.new
        persister.log = log

        persister
      end
    end

  end
end
