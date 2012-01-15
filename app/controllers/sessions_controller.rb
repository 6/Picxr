class SessionsController < ApplicationController

  def create
    user = User.find_by_provider_and_uid(params[:provider], params[:uid]) || User.create_with_omniauth(params)
    session[:user_id] = user.id
    render :nothing => true
  end
  
  def destroy
    session[:user_id] = nil
    redirect_to root_url
  end

end
