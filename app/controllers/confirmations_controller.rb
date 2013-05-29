class ConfirmationsController < Devise::ConfirmationsController
  hdo_force_ssl

  # Remove the first skip_before_filter (:require_no_authentication) if you
  # don't want to enable logged users to access the confirmation page.
  skip_before_filter :require_no_authentication
  skip_before_filter :authenticate_user!

  # PUT /representative/confirmation
  def update
    with_unconfirmed_confirmable do
      if @confirmable.has_no_password?
        if @confirmable.attempt_set_password(params[:representative])
          do_confirm
        else
          do_show
        end
        return
      else
        @confirmable.errors.add(:base, :password_already_set)
      end
    end

    if !@confirmable.errors.empty?
      render 'representative/confirmations/new'
    end
  end

  # GET /representative/confirmation?confirmation_token=abcdef
  def show
    with_unconfirmed_confirmable do
      if @confirmable.has_no_password?
        do_show
      else
        do_confirm
      end
      return
    end
    if @confirmable.errors.any?
      redirect_to new_user_session_path
    end
  end

  protected

  def with_unconfirmed_confirmable
    @confirmable = Representative.find_or_initialize_with_error_by(:confirmation_token, params[:confirmation_token])
    unless @confirmable.new_record?
      @confirmable.only_if_unconfirmed { yield }
    end
  end

  def do_show
    @confirmation_token = params[:confirmation_token]
    @requires_password = true
    self.resource = @confirmable
    render 'representative/confirmations/show'
  end

  def do_confirm
    @confirmable.confirm!
    set_flash_message :notice, :confirmed
    sign_in_and_redirect(resource_name, @confirmable)
  end
end