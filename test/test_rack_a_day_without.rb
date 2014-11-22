require 'minitest_helper'

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
      endpoint = Rack::ADayWithout.new @app, 'Art', on: Date.today
      status, headers, body = endpoint.call(Rack::MockRequest.env_for('/bar'))
      status.must_equal 200
      body.body.must_equal ['']
    end

    it 'passes a request' do
      endpoint = Rack::ADayWithout.new @app, 'Art', on: Date.new
      status, headers, body = endpoint.call(Rack::MockRequest.env_for('/bar'))
      status.must_equal 200
      body.body.must_equal ['Downstream app']
    end

    it 'blocks with supplied content' do
      endpoint = Rack::ADayWithout.new @app, 'Art',
                                       on: Date.today,
                                       content: 'foobar'
      status, headers, body = endpoint.call(Rack::MockRequest.env_for('/bar'))
      status.must_equal 200
      body.body.must_equal ['foobar']
    end

    it 'blocks with supplied file' do
      path = 'test/fixtures/index.html'
      content = File.read(path)
      endpoint = Rack::ADayWithout.new @app, 'Art',
                                       on: Date.today,
                                       file: path
      status, headers, body = endpoint.call(Rack::MockRequest.env_for('/bar'))
      status.must_equal 200
      body.body.must_equal [content]
    end

    it 'passes allowed routes' do
      endpoint = Rack::ADayWithout.new @app, 'Art',
                                       on: Date.today,
                                       allow: '/bar'
      status, headers, body = endpoint.call(Rack::MockRequest.env_for('/bar'))
      status.must_equal 200
      body.body.must_equal ['Downstream app']
    end

    it 'blocks sub-path of allowed routes' do
      endpoint = Rack::ADayWithout.new @app, 'Art',
                                       on: Date.today,
                                       allow: '/bar'
      status, headers, body = endpoint.call(Rack::MockRequest.env_for('/bar/bar'))
      status.must_equal 200
      body.body.must_equal ['']
    end

    it 'passes allowed routes as regexp' do
      endpoint = Rack::ADayWithout.new @app, 'Art',
                                       on: Date.today,
                                       allow: %r{^/bar}
      status, headers, body = endpoint.call(Rack::MockRequest.env_for('/bar/baz'))
      status.must_equal 200
      body.body.must_equal ['Downstream app']
    end

    it 'passes allowed routes as array' do
      endpoint = Rack::ADayWithout.new @app, 'Art',
                                       on: Date.today,
                                       allow: ['/bar', '/baz']
      status, headers, body = endpoint.call(Rack::MockRequest.env_for('/bar'))
      status.must_equal 200
      body.body.must_equal ['Downstream app']
    end

    it 'passes allowed routes as array with regexps' do
      endpoint = Rack::ADayWithout.new @app, 'Art',
                                       on: Date.today,
                                       allow: [%r{^/bar}, '/baz']
      status, headers, body = endpoint.call(Rack::MockRequest.env_for('/bar/baz'))
      status.must_equal 200
      body.body.must_equal ['Downstream app']
    end

    it 'sets HTTP header when blocked' do
      endpoint = Rack::ADayWithout.new @app, 'Art',
                                       on: Date.today
      status, headers, body = endpoint.call(Rack::MockRequest.env_for('/bar'))
      headers['X-Day-Without'].must_equal 'Art'
    end
  end

  describe 'when initialized' do
    it 'parses a date' do
      date = '20/10/2014'
      endpoint = Rack::ADayWithout.new @app, 'Art', on: date
      endpoint.instance_variable_get('@date').must_equal Date.parse(date)
    end

    it 'parses a date' do
      date = '20/10/2014'
      endpoint = Rack::ADayWithout.new @app, 'Art', on: date
      endpoint.instance_variable_get('@date').must_equal Date.parse(date)
    end

    it 'stores a subject' do
      endpoint = Rack::ADayWithout.new @app, 'Art', on: Date.new
      endpoint.instance_variable_get('@subject').must_equal 'Art'
    end

    it 'stores allowed routes in array' do
      endpoint = Rack::ADayWithout.new @app, 'Art', on: Date.new, allow: 'foo'
      endpoint.instance_variable_get('@allowed').must_equal ['foo']
    end
  end

end
