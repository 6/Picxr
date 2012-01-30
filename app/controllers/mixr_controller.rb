require 'open-uri'
class MixrController < ApplicationController
  
  # help solve issues with cross-origin policy for image data
  def proxy
    pic = Picture.get_remote_image(params[:url_or_id], request.path)
    if pic.nil?
      render :text => 'no', :status => 400
    else
      send_file pic[:io], :type => pic[:mime], :disposition => 'inline'
    end
  end
  
  def save
    original = nil
    if params[:original_url]
      pic = Picture.get_remote_image(params[:original_url], request.path)
      unless pic.nil?
        io = pic[:io]
        o = Picture.create(
          :creator_id => session[:user_id],
          :is_private => true
        )
        def io.original_filename
          "from_url_fb.png"
        end
        o.update_attributes(:picture => io)
        original = o.permalink_id
      end
    end
    
    sio = StringIO.new(Base64.decode64(params[:imgdata]))
    sio.class.class_eval { attr_accessor :original_filename, :content_type }
    sio.original_filename = "#{t :app_lower}.png"
    sio.content_type = "image/png"
    original_permalink_id = original.nil? ? params[:original] : original
    picture = Picture.create(
      :creator_id => session[:user_id],
      :is_private => params[:private].nil? ? false : true,
      :original_permalink_id => original_permalink_id
    )
    picture.update_attributes(:picture => sio)
    render :text => picture.permalink_id
  end
end