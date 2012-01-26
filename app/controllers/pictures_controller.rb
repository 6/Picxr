class PicturesController < ApplicationController

  def show
    id = request.path.starts_with?("/p/") ? "p/#{params[:id]}" : params[:id]
    @pic_url = Picture.original_url(id)
    if @pic_url.nil?
      return render :text => 'not found', :status => 404
    end
    @permalink = "#{ENV['PERMALINK_ROOT']}#{id}"
  end
  
  def create
    @pic = Picture.create(:is_private => true, :creator_id => session[:user_id])
    @pic.update_attributes(:picture => params[:picture])
    redirect_to edit_path(CGI.escape(@pic.picture.url(:original, false).gsub(/\./, '@')))
  end
end
