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
    open(url, "rb") do |file|
      if %w[image/jpeg image/png image/gif].include? file.content_type
        mime = file.content_type
      end
      send_file file, :type => mime, :disposition => 'inline'
    end
  end
  
  def save
    bytes = ActiveSupport::Base64.decode64(params[:imgdata])
    send_data bytes, :filename => 'picmixr.png'
  end
end