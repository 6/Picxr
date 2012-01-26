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
  
  private
  
  def set_permalink_id
    if self.is_private
      self.update_attributes(:permalink_id => "p/#{random_permalink_id}")
    else
      self.update_attributes(:permalink_id => BaseEncoder.encode(self.id + 3530000000000))
    end
  end
  
  def random_permalink_id
    random_s = BaseEncoder.encode(rand(1000000000000..10000000000000000000000000000))
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
