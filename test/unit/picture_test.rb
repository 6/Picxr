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
#  created_at           :datetime
#  updated_at           :datetime
#  permalink_id         :string(255)
#  is_private           :boolean
#

require 'test_helper'

class PictureTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
