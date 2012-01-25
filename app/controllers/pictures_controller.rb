class PicturesController < ApplicationController

  def show
    pic = Picture.find_by_b64_id(params[:id])
    if Rails.env.production?
      @pic_url = "http://i.picmixr.com/#{params[:id]}.png"
    else
      @pic_url = pic.picture.url(:original, false)
    end
    @permalink = "#{ENV['PERMALINK_ROOT']}#{params[:id]}"
  end
  
  def create
    @pic = Picture.create(:creator_id => session[:user_id])
    @pic.update_attributes(:picture => params[:picture])
    redirect_to edit_path(CGI.escape(@pic.picture.url(:original, false).gsub(/\./, '@')))
  end
end
