class PicturesController < ApplicationController

  def show
    @pic = Picture.find_by_b64_id(params[:id])
  end
  
  def create
    @pic = Picture.new
    @pic.picture = params[:picture]
    @pic.creator_id = session[:user_id] unless session[:user_id].nil?
    @pic.save
    redirect_to edit_path(CGI.escape(@pic.picture.url(:original, false)).gsub(/\./, '@'))
  end
end
