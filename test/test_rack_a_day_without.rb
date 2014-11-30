require 'minitest_helper'

TWENTY_FOUR_HOURS = (60 * 60 * 24)

describe Rack::ADayWithout do

  it 'must have a version number' do
    Rack::ADayWithout::VERSION.wont_be_nil
  end

  describe 'when used as middleware' do
    before do
      @app = Proc.new do
        Rack::Response.new {|r| r.write 'Downstream app'}.finish
      end
    end

    it 'blocks a request' do
      endpoint = Rack::ADayWithout.new @app, 'Art', on: today
      status, headers, body = endpoint.call(Rack::MockRequest.env_for('/bar'))
      status.must_equal 200
      body.body.must_equal ['']
    end

    it 'passes a request' do
      endpoint = Rack::ADayWithout.new @app, 'Art', on: tomorrow
      status, headers, body = endpoint.call(Rack::MockRequest.env_for('/bar'))
      status.must_equal 200
      body.body.must_equal ['Downstream app']
    end

    it 'blocks with supplied content' do
      endpoint = Rack::ADayWithout.new @app, 'Art',
                                       on: today,
                                       content: 'foobar'
      status, headers, body = endpoint.call(Rack::MockRequest.env_for('/bar'))
      status.must_equal 200
      body.body.must_equal ['foobar']
    end

    it 'blocks with supplied file' do
      path = 'test/fixtures/index.html'
      content = File.read(path)
      endpoint = Rack::ADayWithout.new @app, 'Art',
                                       on: today,
                                       file: path
      status, headers, body = endpoint.call(Rack::MockRequest.env_for('/bar'))
      status.must_equal 200
      body.body.must_equal [content]
    end

    it 'passes allowed routes' do
      endpoint = Rack::ADayWithout.new @app, 'Art',
                                       on: today,
                                       bypass: '/bar'
      status, headers, body = endpoint.call(Rack::MockRequest.env_for('/bar'))
      status.must_equal 200
      body.body.must_equal ['Downstream app']
    end

    it 'blocks sub-path of allowed routes' do
      endpoint = Rack::ADayWithout.new @app, 'Art',
                                       on: today,
                                       bypass: '/bar'
      status, headers, body = endpoint.call(Rack::MockRequest.env_for('/bar/bar'))
      status.must_equal 200
      body.body.must_equal ['']
    end

    it 'passes allowed routes as regexp' do
      endpoint = Rack::ADayWithout.new @app, 'Art',
                                       on: today,
                                       bypass: %r{^/bar}
      status, headers, body = endpoint.call(Rack::MockRequest.env_for('/bar/baz'))
      status.must_equal 200
      body.body.must_equal ['Downstream app']
    end

    it 'passes allowed routes as array' do
      endpoint = Rack::ADayWithout.new @app, 'Art',
                                       on: today,
                                       bypass: ['/bar', '/baz']
      status, headers, body = endpoint.call(Rack::MockRequest.env_for('/bar'))
      status.must_equal 200
      body.body.must_equal ['Downstream app']
    end

    it 'passes allowed routes as array with regexps' do
      endpoint = Rack::ADayWithout.new @app, 'Art',
                                       on: today,
                                       bypass: [%r{^/bar}, '/baz']
      status, headers, body = endpoint.call(Rack::MockRequest.env_for('/bar/baz'))
      status.must_equal 200
      body.body.must_equal ['Downstream app']
    end

    it 'sets HTTP header when blocked' do
      endpoint = Rack::ADayWithout.new @app, 'Art', on: today
      status, headers, body = endpoint.call(Rack::MockRequest.env_for('/bar'))
      headers['X-Day-Without'].must_equal 'Art'
    end

    it 'obeys timezones' do
      now = timezone('America/New_York').now
      midnight = now + TWENTY_FOUR_HOURS - now.to_i % TWENTY_FOUR_HOURS + 10
      frozen_today = midnight.to_date
      Time.stub :now, midnight do
        endpoint = Rack::ADayWithout.new @app, 'Art',
          on: frozen_today,
          timezone: 'America/Los_Angeles'
        endpoint.today.wont_equal endpoint.date
      end
    end
  end

  describe 'when initialized' do
    it 'parses a date' do
      date = '20/10/2014'
      endpoint = Rack::ADayWithout.new @app, 'Art', on: date
      endpoint.date.must_equal Date.parse(date)
    end

    it 'parses a date' do
      date = '20/10/2014'
      endpoint = Rack::ADayWithout.new @app, 'Art', on: date
      endpoint.date.must_equal Date.parse(date)
    end

    it 'stores a subject' do
      endpoint = Rack::ADayWithout.new @app, 'Art', on: tomorrow
      endpoint.subject.must_equal 'Art'
    end

    it 'stores a default timezone' do
      endpoint = Rack::ADayWithout.new @app, 'Art', on: today
      endpoint.timezone.name.must_equal 'GMT'
    end

    it 'stores a timezone' do
      tz = 'America/New_York'
      endpoint = Rack::ADayWithout.new @app, 'Art', on: today, timezone: tz
      endpoint.timezone.name.must_equal tz
    end

    it 'stores allowed routes in array' do
      endpoint = Rack::ADayWithout.new @app, 'Art', on: tomorrow, bypass: 'foo'
      endpoint.allowed_paths.must_equal ['foo']
    end
  end

  describe 'when dynamically subclassed' do
    it 'creates a subclass' do
      endpoint = Rack::ADayWithout::Art
      endpoint.name.must_equal "Rack::ADayWithout::Art"
      endpoint.ancestors.must_include Rack::ADayWithout
    end

    it 'store subject by name' do
      endpoint = Rack::ADayWithout::Art.new @app, on: today
      endpoint.subject.must_equal 'Art'
    end
  end

end
