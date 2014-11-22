require "date"
require "rack"
require "rack/a_day_without/version"

module Rack
  class ADayWithout

    def initialize app, subject, options = {}
      @app = app
      @subject = subject
      @date = Date.parse(options[:on].to_s)
      @content = parse_content(options)
    end

    def call env
      if @date == Date.today
        res = Response.new
        res.write @content
        res.finish
      else
        @app.call env
      end
    end

    private

    def parse_content options
      if options[:file]
        ::File.read(options[:file])
      else
        options[:content] || ''
      end
    end

  end
end
