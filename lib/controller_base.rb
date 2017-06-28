require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative './session'
require 'active_support/inflector'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res)
    @req = req
    @res = res
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    raise "already rendered "if already_built_response?
    @res['Location'] = url
    @res.status = 302
    @session.store_session(@res)
    @already_built_response = true
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    raise "already rendered "if already_built_response?
    @res['Content-Type'] = content_type
    @res.write(content)
    @session.store_session(@res)
    @already_built_response = true
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    controller_name = self.class.name.underscore
    directory_path = File.dirname(__FILE__)
    # path_to = File.join(directory_path, controller_name, "#{template_name}.html.erb")
    # contents = File.read(path_to)
    contents = File.read("/home/greenteamuimui/AAbootcamp/W5D2/skeleton/views/#{controller_name}/#{template_name}.html.erb")
    # grabbed_content = ERB.new("<%= contents %>").result(binding)
    grabbed_content = ERB.new(contents).result(binding) #contents does not have to be in %= because the html file already contains erb tags
    render_content(grabbed_content, 'text/html')
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    self.send(name)
    render(name.to_s) if already_built_response?
  end
end
