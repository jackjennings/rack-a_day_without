# Rack::ADayWithout

[![Build Status](https://travis-ci.org/jackjennings/rack-a_day_without.svg)](https://travis-ci.org/jackjennings/rack-a_day_without)
[![Gem Version](https://badge.fury.io/rb/rack-a_day_without.svg)](http://badge.fury.io/rb/rack-a_day_without)

`Rack::ADayWithout` is a middleware for Rack-based web applications, originally built to display alternate content for the [Day Without Art](https://en.wikipedia.org/wiki/Day_Without_Art). All requests on a given day will be served blank or alternate content.

## Installation

Add this line to your application's Gemfile:

    gem 'rack-a_day_without', require: 'rack/a_day_without'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rack-a_day_without

## Usage

Use `Rack::ADayWithout` as a middleware in your Rack (or Rails) application. The first parameter defines the `subject` of ADayWithout. The `on` option must be set to the date the middleware should inject the alternate content. `on` should be either a string that can be parsed by `Date.parse` or an instance of `Date`.

```ruby
use Rack::ADayWithout, 'Art', on: '1/12/2014'
```

You can also use the alternate syntax which uses child classes to set the `subject` of ADayWithout. This is equivalent to the above example:

```ruby
use Rack::ADayWithout::Art, on: '1/12/2014'
```

The child class is generated dynamically, and doesn't need to be defined beforehand. Thus the following are all valid:

```ruby
use Rack::ADayWithout::War, on: '1/1/2100'
use Rack::ADayWithout::Pizza, on: '1/2/3456'
use Rack::ADayWithout::Foo, on: '15/7/2020'
```

### Setting Timezone

By default `ADayWithout` will use GMT dates. You can set the `timezone` option for the middleware to use a different timezone that `tzinfo` knows about.

```ruby
use Rack::ADayWithout::Art, on: '1/12/2014', timezone: 'America/New_York'
```

### Writing Content

By default, the middleware will write an empty content string for all requests on the specified day. If the `content` or `file` options are set, the content string or file contents will be written instead.

```ruby
use Rack::ADayWithout::Art, on: '1/12/2014', content: 'A Day Without Art'
# or...
use Rack::ADayWithout::Art, on: '1/12/2014', file: './public/index.html'
```

### Bypass Routes

The `bypass` option allows some routes to pass through the middleware without being blocked. This can be useful if you have an admin area that should still be available during the day without. `bypass` can be set to be a `String`, a `Regexp` or an `Array` of either.

```ruby
use Rack::ADayWithout::Art, on: '1/12/2014',
  bypass: [/^\/admin/, '/about']
```

## With Rails

Load the rack middleware inside of `config/application.rb`:

```ruby
module YourApp
  class Application < Rails::Application
    # ...

    config.middleware.use Rack::ADayWithout::Art, on: '22/11/2014'
  end
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
