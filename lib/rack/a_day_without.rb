require "date"
require "rack"
require "rack/a_day_without/version"

module Rack
  class ADayWithout

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
      @content = options[:content]
      @file = options[:file]
      @date = parse_date options[:on]
      @allowed = parse_allowed_routes options[:allow]
    end

    def call env
      allowed = allowed_path? env['PATH_INFO']
      if @date == Date.today && !allowed
        res = Response.new
        res["X-Day-Without"] = @subject
        res.write content
        res.finish
      else
        @app.call env
      end
    end

    private

    def content
      if @file
        ::File.read @file
      else
        @content.to_s
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

    def parse_date dateish
      Date.parse dateish.to_s
    end

    def allowed_path? path
      @allowed.any? do |a|
        a.is_a?(Regexp) ? a.match(path.to_s) : a == path.to_s
      end
    end

  end
end
