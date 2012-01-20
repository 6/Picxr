# Source:
# http://stackoverflow.com/questions/4046960/how-to-redirect-without-www-using-rails-3-rack
class NoWww

  def initialize(app)
    @app = app
  end

  def call(env)

    request = Rack::Request.new(env)

    if request.host.starts_with?("www.")
      [301, {"Location" => request.url.sub("//www.", "//")}, self]
    else
      @app.call(env)
    end
  end

  def each(&block)
  end

end
