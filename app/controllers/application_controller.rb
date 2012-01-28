class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :set_debug, :set_locale
  helper_method :current_user
  
  private
  
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  
  def set_debug
    @debug = Rails.env.development? || !params[:debug].nil? ? 'yes' : 'no'
  end

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end
  
end
