require 'opal-jquery'
require 'singleton'
require 'observer'

module Router

  class SessionCookie
    include Singleton
    include Observable

    def initialize
      Document.ready? do
        if logged_in?
          changed
          notify_observers :logged_in
        end
      end
    end

    def login
      `document.cookie = 'logged_in=true'`
      changed
      notify_observers :logged_in
    end

    def logout
      `document.cookie = 'logged_in=false'`
      changed
      notify_observers :logged_out
    end

    def logged_in?
      match = `document.cookie`.scan(/logged_in=([^;]*)/)
      return false if match.empty?
      logged_in = match.flatten.first
      logged_in == 'true'
    end

  end


  def self.configure
    yield routes if block_given?
    raise 'no default route set' unless routes.default_route
  end

  def self.add_path_observer(observer)
    raise 'no route defined, configure routes first' if @routes.nil?
    @routes.add_observer(observer, :path_update)
  end

  def self.add_login_observer(observer)
    SessionCookie.instance.add_observer(observer, :login_update)
  end

  def self.login
    SessionCookie.instance.login
    @routes.redirect_to @default_route
  end

  def self.logout
    SessionCookie.instance.logout
    @routes.redirect_to @auth_route
  end

  private

  def self.routes
    @routes ||= Routes.new
  end

  class Routes
    include Observable
    attr_reader :default_route
    attr_reader :auth_route

    def initialize
      @routes = []

      $global.addEventListener 'hashchange', -> { update }, false
      Document.ready? do
        update
      end

    end

    def add(route, param = :standard)
      @routes << {route: route, param: param}
      @auth_route    = route if param == :auth
      @default_route = route if param == :default
    end

    def redirect_to path
      $global.location.hash = "#/#{path}"
    end

    def current_path
      $global.location.hash.sub(/^#\/*/, '')
    end

    private

    def update

      # redirect to login page if needed
      if @auth_route
        if current_path != @auth_route
          # list of public routes where we doesn't need to be logged in
          public_routes = @routes.map{|r| r[:route] if r[:param]==:public}.compact
          unless public_routes.include?(current_path)
            unless SessionCookie.instance.logged_in? # are we logged in?
              redirect_to @auth_route
              return
            end
          end
        end
      end

      # redirect to default route if the route doesn't exist
      unless @routes.map{|r| r[:route]}.include?(current_path)
        redirect_to @default_route
        return
      end

      # Call Ruby Observer methods
      changed
      notify_observers current_path

    end # update

  end # Route
end # Router
