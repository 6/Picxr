Rails.application.config.middleware.use OmniAuth::Builder do
  scope = {:scope => 'user_photos,friends_photos'}
  if Rails.env.production?
    provider :facebook, ENV["FACEBOOK_APP_ID"], ENV["FACEBOOK_SECRET"], scope
  else
    provider :facebook, "207270859352264", "c57d75025833869ae9b0cee2578f6058", scope
  end
end
