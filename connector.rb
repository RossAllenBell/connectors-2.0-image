require 'sinatra/base'
require 'elastic-apm'
require 'ecs_logging/middleware'
require 'elastic-enterprise-search'

require './config'

class Connector < Sinatra::Base
  use ElasticAPM::Middleware
  use EcsLogging::Middleware, $stdout

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

  post '/index' do
    http_auth = {user: config_yml.dig('elastic', 'enterprise_search', 'username'), password: config_yml.dig('elastic', 'enterprise_search', 'password')}
    host = config_yml.dig('elastic', 'enterprise_search', 'host')

    client = Elastic::EnterpriseSearch::WorkplaceSearch::Client.new(host: host, http_auth: http_auth)

    client.list_content_sources.to_json
  end
end
