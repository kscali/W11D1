require 'erb'
require 'byebug'

class ShowExceptions
  attr_reader :app

  def initialize(app)
    @app = app
  end

  def call(env)
    begin
      app.call(env)
    rescue Exception => e
      render_exception(e)
    end
  end

  private

  def render_exception(e)
    path = File.dirname(__FILE__)
    full_path = File.join(path, "templates", "rescue.html.erb")
    template = File.read(full_path)
    body = ERB.new(template).result(binding)
    ['500', {'Content-type' => 'text/html'}, body]
  end

end

