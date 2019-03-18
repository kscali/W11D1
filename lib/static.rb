require 'byebug'

class Static
  attr_reader :app

  def initialize(app)
    @app = app
  end

  def call(env)
    req = Rack::Request.new(env)
    filename = File.basename(req.path)
    folder_loc = File.dirname(__FILE__)
    asset_loc = File.join(folder_loc, "..", "public", filename)

    app.call(env)
    res = Rack::Response.new

    if File.exist?(asset_loc)
      content = File.read(asset_loc)
      
      res.status = 200
      res['Content-type'] = 'text/html'
      res.write(content)
    else
      res.status = 404
    end

    res
  end
end
