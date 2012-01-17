# Load the rails application
require File.expand_path('../application', __FILE__)

# Load heroku vars from local file
if Rails.env.development?
  heroku_env = Rails.root.join('config', 'heroku_env.rb')
  load(heroku_env) if File.exists?(heroku_env)
end

# Initialize the rails application
PicMixr::Application.initialize!
