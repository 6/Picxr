class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :set_is_dev
  helper_method :current_user
  
  private
  
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  
  def set_is_dev
    @is_dev = Rails.env.development? || !params[:dev].nil? ? 'yes' : 'no'
  end
  
end
