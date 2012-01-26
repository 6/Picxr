class PicturesController < ApplicationController

  def show
    id = request.path.starts_with?("/p/") ? "p/#{params[:id]}" : params[:id]
    pic = Picture.find_by_permalink_id(id)
    if Rails.env.production?
      @pic_url = "http://i.picmixr.com/#{id}.png"
    else
      @pic_url = pic.picture.url(:original, false)
    end
    @permalink = "#{ENV['PERMALINK_ROOT']}#{id}"
  end
  
  def create
    @pic = Picture.create(:is_private => true, :creator_id => session[:user_id])
    @pic.update_attributes(:picture => params[:picture])
    redirect_to edit_path(CGI.escape(@pic.picture.url(:original, false).gsub(/\./, '@')))
  end
end
