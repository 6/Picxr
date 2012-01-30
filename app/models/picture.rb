# == Schema Information
#
# Table name: pictures
#
#  id                    :integer         not null, primary key
#  picture_file_name     :string(255)
#  picture_content_type  :string(255)
#  picture_file_size     :integer
#  picture_updated_at    :datetime
#  original_permalink_id :string(255)
#  creator_id            :integer
#  created_at            :datetime
#  updated_at            :datetime
#  permalink_id          :string(255)
#  is_private            :boolean
#

require 'base_encoder'

class Picture < ActiveRecord::Base
  delegate :url_helpers, to: 'Rails.application.routes'
  after_create :set_permalink_id
  
  has_attached_file :picture,
    :storage => :s3,
    :path => ":permalink_id.:extension",
    :bucket => ENV['S3_BUCKET'],
    :s3_protocol => 'https',
    :s3_credentials => {
      :access_key_id => ENV['S3_KEY'],
      :secret_access_key => ENV['S3_SECRET']
    }
  validates_attachment_content_type :picture, :content_type => /image/
  
  def self.from_path(relative_path)
    if relative_path =~ /^\/((iproxy|dl)\/)?p\//
      # private permalink ID
      id = relative_path.split("/")[-2..-1].join("/")
    else
      # public permalink ID
      id = relative_path.split("/")[-1]
    end
    Picture.find_by_permalink_id(id)
  end
  
  def self.get_remote_image(url_or_id, relative_path)
    url = url_or_id.strip.gsub("@", ".")
    if url.starts_with?("http://", "https://", "ftp://")
      is_url = true
    elsif url =~ /\./
      is_url = true
      # TODO improve
      url = "http://#{url}"
    end
    if is_url
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
    else
      pic = Picture.from_path(relative_path)
      return nil if pic.nil?
      return nil if pic.picture == "/pictures/original/missing.png"
      url = pic.picture.url(:original)
      mime = pic.picture.content_type
    end
    begin
      io = open(url)
      if %w[image/jpeg image/png image/gif].include? io.content_type
        mime = io.content_type
      end
      return {:io => io, :mime => mime}
    rescue
      return nil
    end
  end
  
  def direct_link
    if Rails.env.production?
      ext = self.picture.url(:original, false).split(".")[-1]
      "http://i.#{ENV['PERMALINK_ROOT']}/#{self.permalink_id}.#{ext}"
    else
      self.picture.url(:original, false)
    end
  end
  
  def clean_permalink_id
    if self.permalink_id.starts_with?("p/")
      return self.permalink_id[2..-1]
    else
      return self.permalink_id
    end
  end
  
  def edit_link
    self.is_private ? url_helpers.edit_private_path(self.clean_permalink_id) : url_helpers.edit_path(self.permalink_id)
  end
  
  def permalink
    "http://#{ENV['PERMALINK_ROOT']}/#{self.permalink_id}"
  end
  
  private
  
  def set_permalink_id
    if self.is_private
      self.update_attributes(:permalink_id => "p/#{random_permalink_id}")
    else
      self.update_attributes(:permalink_id => BaseEncoder.encode(self.id + 57000000000))
    end
  end
  
  def random_permalink_id
    random_s = BaseEncoder.encode(Random.new.rand(1000000000000..10000000000000000000000000000))
    count = Picture.where(:permalink_id => random_s).count()
    if count > 0
      return random_permalink_id
    else
      return random_s
    end
  end
  
  Paperclip.interpolates :permalink_id do |picture, style|
    picture.instance.permalink_id
  end
end
