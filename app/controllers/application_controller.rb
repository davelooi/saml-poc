class ApplicationController < ActionController::Base
  before_action :authenticate!

  def current_user
    @current_user ||= User.where(id: session[:user_id]).first
  end

  def current_admin_user
    current_user
  end

  def authenticate!
    return current_user if current_user

    redirect_to init_saml_index_url
  end

  def authenticate_admin_user!
    authenticate!
  end
end
