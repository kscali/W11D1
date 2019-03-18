require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative './session'
require 'active_support/inflector'
require_relative './flash'
require 'byebug'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res, route_params = {})
    @req = req 
    @res = res
    @params = route_params.merge(req.params)
    @already_built_response = false 
   end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response 
  end

  # Set the response status code and header
  def redirect_to(url)
    raise "Can't double render" if @already_built_response
    flash.store_flash(@res)
    @res.status = 302
    @res.set_header('Location', url)
    @already_built_response = true 
    session.store_session(@res)
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    
    if @already_built_response
     raise "Can't double render"
    else 
      session.store_session(@res)
      flash.store_flash(@res)
      # debugger
      @res['Content-Type'] = content_type
      @res.write(content)
      @already_built_response = true 
      
    end 
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    path = File.dirname(__FILE__)
    full_path = File.join(path, "..", "views", "#{self.class.name.underscore}", "#{template_name}.html.erb")
    template = File.read(full_path)
    render_content(
      ERB.new(template).result(binding),
      "text/html"
    )
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    check_authenticity_token
    self.send(name)
    render name if !already_built_response?
  end

  def flash
    @flash ||= Flash.new(@req)
  end

  def form_authenticity_token
    @token ||= SecureRandom::urlsafe_base64(16)
    res.set_cookie('authenticity_token', {value: @token, path: '/'})
    @token
  end

  def check_authenticity_token

  end

  def self.protect_from_forgery

  end
end

