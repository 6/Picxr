require 'open-uri'
class MixrController < ApplicationController
  
  # help solve issues with cross-origin policy for image data
  def proxy
    url = params[:url].strip
    unless url.starts_with?("http://", "https://", "ftp://")
      url = "http://#{url}"
    end
    url = url.gsub("@", ".")
    ext = url.split(".").last
    # guess MIME type from file extension
    mime = case ext
    when "gif"
      "image/gif"
    when "png"
      "image/png"
    else
      "image/jpeg"
    end
    begin
      open(url, "rb") do |file|
        if %w[image/jpeg image/png image/gif].include? file.content_type
          mime = file.content_type
        end
        send_file file, :type => mime, :disposition => 'inline'
      end
    rescue
      render :text => 'no', :status => 400
    end
  end
  
  def save
    sio = StringIO.new(Base64.decode64(params[:imgdata]))
    sio.class.class_eval { attr_accessor :original_filename, :content_type }
    sio.original_filename = "picmixr.png"
    sio.content_type = "image/png"
    picture = Picture.create(
      :creator_id => session[:user_id],
      :is_private => params[:private].nil? ? false : true
    )
    picture.update_attributes(:picture => sio)
    render :text => picture.permalink_id
  end
end