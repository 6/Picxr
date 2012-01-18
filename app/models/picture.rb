class Picture < ActiveRecord::Base
  has_attached_file :picture,
    :storage => :s3,
    :path => ":id-:style.:extension",
    :bucket => ENV['S3_BUCKET'],
    :s3_protocol => 'https',
    :s3_credentials => {
      :access_key_id => ENV['S3_KEY'],
      :secret_access_key => ENV['S3_SECRET']
    }
end
