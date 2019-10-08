class ApplicationController < ActionController::Base
  include Pagy::Backend

  protect_from_forgery with: :exception

  before_action :set_beginning_of_week

  before_action :configure_permitted_parameters, if: :devise_controller?

  private

  def set_beginning_of_week
    config.beginning_of_week = :sunday
    Date.beginning_of_week = :sunday
  end

  protected


  def configure_permitted_parameters
    added_attrs = [:username, :email, :password, :password_confirmation, :remember_me]
    devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
    devise_parameter_sanitizer.permit :account_update, keys: added_attrs
    devise_parameter_sanitizer.permit :accept_invitation, keys: [:email]


    # devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :invite_code])
    # devise_parameter_sanitizer.permit(:account_update, keys: [:name, :invite_code])
  end
end
