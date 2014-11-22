require "rack"
require "rack/a_day_without/version"

module Rack
  class ADayWithout

    def initialize app, options = {}
      @app = app
      @options = options
    end

    def call env
      @app.call env
    end

  end
end
