require 'sinatra/base'
require 'yaml'
require 'elastic-apm'

class Connector < Sinatra::Base
  use ElasticAPM::Middleware

  configure do
    set :environment, :production
    set :port, 80
    enable :logging
  end

  get '/' do
    'Why, hello.'
  end

  get '/error' do
    this_will_error
  end
end
