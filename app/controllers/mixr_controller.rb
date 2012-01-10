require 'open-uri'
class MixrController < ApplicationController
  
  # help solve issues with cross-origin policy for image data
  def proxy
    url = params[:url].gsub("@", ".")
    ext = url.split(".").last
    # TODO get MIME type from requesting server
    mime = case ext
    when "gif"
      #TODO what if GIF is animated?
      "image/gif"
    when "png"
      "image/png"
    else
      "image/jpeg"
    end
    open(url, "rb") do |file|
      send_file file, :type => mime, :disposition => 'inline'
    end
  end
end