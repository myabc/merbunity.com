module MultipartHelper
  
  def multipart_request(path, params = {}, &block)
    request = request_with_multipart_params(path, params)
    check_request_for_route(request)
    klass = request.controller_class
    @controller = klass.build(request, response, 200)
    yield @controller if block_given?
    @controller.dispatch(request.action)
  end
  
  def multipart_post(path, params = {}, &block)
    multipart_request(path, params.merge!(:request_method => 'POST'), &block)
  end
  
  def multipart_put(path, params = {}, &block)
    multipart_request(path, params.merge!(:request_method => 'PUT'), &block)
  end
  
  def request_with_multipart_params(path, params = {})
    request_method = params.delete(:request_method) || "GET"
    request = Merb::Test::FakeRequest.new(:request_uri => path)
    m = Merb::Test::Multipart::Post.new(params)
    body, head = m.to_multipart
    request['REQUEST_METHOD'] = request_method
    request['CONTENT_TYPE'] = head
    request['CONTENT_LENGTH'] = body.length
    request.post_body = body
    request = Merb::Request.new(request)
  end
  
  def check_request_for_route(request)
    if request.route_params.empty?
      raise ControllerExceptions::BadRequest, "No routes match the request"
    elsif request.controller_name.nil?
      raise ControllerExceptions::BadRequest, "Route matched, but route did not specify a controller" 
    end
  end
  
end

module Merb
  module Test
    module Multipart
      class Post

        def push_params(params, prefix = nil)
          params.sort_by {|k| k.to_s}.each do |key, value|
            param_key = prefix.nil? ? key : "#{prefix}[#{key}]"
            if value.respond_to?(:read)
              @multipart_params << FileParam.new(param_key, value.path, value.read)
            else
              if value.is_a?(Hash) || value.is_a?(Mash)
                value.keys.each do |k|
                  push_params(value, param_key)
                end
              else
                @multipart_params << Param.new(param_key, value)
              end
            end
          end
        end
      
      end
    end
  end
end
