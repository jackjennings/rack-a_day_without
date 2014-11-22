require "date"
require "rack"
require "rack/a_day_without/version"

module Rack
  class ADayWithout

    def initialize app, subject, options = {}
      @app = app
      @subject = subject
      @date = Date.parse options[:on].to_s
      @content = parse_content options
      @allowed = parse_allowed_routes options[:allow]
    end

    def call env
      allowed = allowed_path? env['PATH_INFO']
      if @date == Date.today && !allowed
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
        ::File.read options[:file]
      else
        options[:content] || ''
      end
    end

    def parse_allowed_routes allowed
      if allowed.nil?
        []
      elsif allowed.respond_to? :to_ary
        allowed.to_ary || [allowed]
      else
        [allowed]
      end
    end

    def allowed_path? path
      @allowed.any? do |a|
        a.is_a?(Regexp) ? a.match(path.to_s) : a == path.to_s
      end
    end

  end
end
