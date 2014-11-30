$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'rack/a_day_without'

require 'minitest'
require 'minitest/autorun'

def today timezone = 'GMT'
  timezone(timezone).now.to_date
end

def tomorrow timezone = 'GMT'
  timezone(timezone).now.to_date + 1
end

def timezone name
  TZInfo::Timezone.get name
end
