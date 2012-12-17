unless Rails.application.config.cache_classes

  #
  # Marshal.load isn't aware of Rails autoloading, so we hack it
  # in here to avoid 'undefined class/module' errors when
  # auto-loaded classes are Marshal.load'ed before the class is loaded.
  #
  # This typically happens when e.g. a model has been cached in Rails.cache
  #
  # This won't affect production where cache_classes is set to true.
  #

  class << Marshal
    def load_with_rails_autoload(*args)
      load_without_rails_autoload(*args)
    rescue ArgumentError, NameError => ex
      raise unless ex.message =~ /undefined class\/module (.+)/
      $1.constantize
      retry
    end

    alias_method_chain :load, :rails_autoload
  end

end
