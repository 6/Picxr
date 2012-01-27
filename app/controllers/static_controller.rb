class StaticController < ApplicationController
  before_filter :generate_permalink
  
  private
  
  def generate_permalink
    @permalink = "http://#{ENV['PERMALINK_ROOT']}#{request.path}"
  end
end
