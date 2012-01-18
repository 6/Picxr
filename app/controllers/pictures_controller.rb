class PicturesController < ApplicationController

  def show
    id = UrlSafeBase64.decode64(params[:id]).to_i
    @pic = Picture.find(id)
  end
end
