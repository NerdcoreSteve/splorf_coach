class ApplicationController < ActionController::Base
  include Pundit
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :authenticate_user!

  private

  def user_not_authorized
    flash[:error] = "You are not authorized to perform this action."
    #TODO can the user be redirected to whatever the previous page was?
    redirect_to(request.referrer || root_path)
  end
end
