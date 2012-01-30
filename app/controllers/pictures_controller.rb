class PicturesController < ApplicationController

  def show
    @pic = Picture.from_path(request.path)
    if @pic.nil?
      return render :text => 'not found', :status => 404
    end
    if @pic.original_permalink_id?
      @original = Picture.find_by_permalink_id(@pic.original_permalink_id)
    end
  end
  
  def create
    @pic = Picture.new(:is_private => true, :creator_id => session[:user_id])
    if @pic.save
      @pic.update_attributes(:picture => params[:picture])
      redirect_to edit_private_path(@pic.clean_permalink_id)
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
  
  def create_from_url
    pic = Picture.get_remote_image(params[:url], request.path)
    if pic.nil?
      flash[:alert] = 'Please specify a valid image URL.'
      return redirect_to upload_path("url")
    end
    io = pic[:io]
    picture = Picture.create(
      :creator_id => session[:user_id],
      :is_private => true
    )
    def io.original_filename
      "from_url.png"
    end
    picture.update_attributes(:picture => io)
    redirect_to edit_private_path(picture.clean_permalink_id)
  end
end
