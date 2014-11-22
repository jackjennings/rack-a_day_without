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

    it 'acts as a middleware' do
      endpoint = Rack::ADayWithout.new @app
      status, headers, body = endpoint.call(Rack::MockRequest.env_for('/bar'))
      status.must_equal 200
      body.body.must_equal ['Downstream app']
    end
  end

end
