class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def auth_user
    redirect_to nocansee_path unless user_signed_in? && current_user.admin?
  end

end
