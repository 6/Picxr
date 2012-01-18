class PicturesController < ApplicationController

  def show
    @pic = Picture.find_by_b64_id(params[:id])
  end
end
