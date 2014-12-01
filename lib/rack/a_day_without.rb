require "date"
require "tzinfo"
require "uri"
require "rack"
require "rack/a_day_without/version"

module Rack
  class ADayWithout

    attr_accessor :subject

    def self.const_missing const_name
      const_set const_name, self.new_subject_subclass
    end

    def self.new_subject_subclass
      Class.new(self) do
        def initialize app, options = {}
          subject = self.class.name.split('::').last
          super app, subject, options
        end
      end
    end

    def initialize app, subject, options = {}
      @app = app
      @subject = subject
      @options = {
        timezone: 'GMT',
        disabled_on: false
      }.merge options
    end

    def call env
      request = Request.new env

      return @app.call env unless request.get? && !request.xhr?

      if disabling_query? request
        disable! request
        @app.call env
      elsif !disabled?(request) && date == today && !allowed?(request)
        block request
      else
        @app.call env
      end
    end

    def timezone
      @timezone ||= parse_timezone @options[:timezone]
    end

    def date
      @date ||= parse_date @options[:on]
    end

    def allowed_paths
      @allowed ||= parse_allowed_routes @options[:bypass]
    end

    def today
      timezone.now.to_date
    end

    def content
      if @options[:file]
        ::File.read @options[:file]
      else
        @options[:content].to_s
      end
    end

    def allowed? request
      allowed_path? request.path_info
    end

    def allowed_path? path
      allowed_paths.any? do |a|
        a.is_a?(Regexp) ? a.match(path.to_s) : a == path.to_s
      end
    end

    def disabling_query? request
      key = @options[:disabled_on]
      key != false && request.params.keys.include?(key)
    end

    def disable! request
      if defined?(ActionDispatch::Request)
        request = ActionDispatch::Request.new(request.env)
        request.cookie_jar[:day_with] = { value: true, path: '/' }
      end
    end

    def disabled? request
      if defined?(ActionDispatch::Request)
        request = ActionDispatch::Request.new(request.env)
        request.cookie_jar[:day_with] || false
      else
        false
      end
    end

    private

    def redirect request
      params = request.params
      params.delete @options[:disabled_on]
      query = URI.encode params.map {|k,v| "#{k}=#{v}"}.join("&")
      location = [request.scheme, '://', request.host, request.path].join
      location << "?#{query}" unless query.empty?

      Response.new do |r|
        r.redirect location
      end.finish
    end

    def block request
      Response.new do |r|
        r["X-Day-Without"] = subject
        r.write content
      end.finish
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

    def parse_date dateish
      Date.parse dateish.to_s
    end

    def parse_timezone timezone
      TZInfo::Timezone.get timezone
    end

  end
end
