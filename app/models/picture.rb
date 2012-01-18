# == Schema Information
#
# Table name: pictures
#
#  id                   :integer         not null, primary key
#  picture_file_name    :string(255)
#  picture_content_type :string(255)
#  picture_file_size    :integer
#  picture_updated_at   :datetime
#  original_url         :string(255)
#  creator_id           :integer
#  private_id           :string(255)
#  created_at           :datetime
#  updated_at           :datetime
#  b64_id               :string(255)
#

require 'base_encoder'

class Picture < ActiveRecord::Base
  after_create :set_b64_id
  
  has_attached_file :picture,
    :storage => :s3,
    :path => ":id.:extension",
    :bucket => ENV['S3_BUCKET'],
    :s3_protocol => 'https',
    :s3_credentials => {
      :access_key_id => ENV['S3_KEY'],
      :secret_access_key => ENV['S3_SECRET']
    }
  
  private
  
  def set_b64_id
    self.update_attributes(:b64_id => BaseEncoder.encode(self.id + 3530000000000))
  end
end
