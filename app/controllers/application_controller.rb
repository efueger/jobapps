class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :site_texts
  before_action :current_user
  layout 'application'

  private

  def current_user
    @current_user = User.find session[:user_id]
  end

  def site_texts
    @site_texts = SiteText.order :name
  end
end
