module Merb
  module GlobalHelpers
    # helpers defined here available to all views.
    def main_nav_link(text, url, opts = {})
      if url == "/"
        opts[:class] = "current" if request.env["REQUEST_PATH"] == url
      elsif request.env["REQUEST_PATH"] && request.env["REQUEST_PATH"].match(%r{^#{url}})
        opts[:class] = "current"
      end
      link_to(text, url, opts)
    end

    def logged_in?
      session.authenticated?
    end
  end
end
