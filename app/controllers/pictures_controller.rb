class PicturesController < ApplicationController

  def show
    @pic = Picture.from_path(request.path)
    if @pic.nil?
      return render :text => 'not found', :status => 404
    end
    @permalink = "http://#{ENV['PERMALINK_ROOT']}/#{@pic.permalink_id}"
  end
  
  def create
    @pic = Picture.new(:is_private => true, :creator_id => session[:user_id])
    if @pic.save
      @pic.update_attributes(:picture => params[:picture])
      redirect_to edit_path(CGI.escape(@pic.picture.url(:original, false).gsub(/\./, '@')))
    else
      flash[:alert] = 'Please specify a valid image.'
      redirect_to upload_path("desktop")
    end
  end
  
  def download
    @pic = Picture.from_path(request.path)
    if @pic.nil?
      render :text => 'not found', :status => 404
    else
      begin
        open(@pic.direct_link, "rb") do |file|
          send_file file, :type => "image/png", :filename => 'picxr.png'
        end
      rescue
        render :text => 'not found', :status => 404
      end
    end
  end
end
