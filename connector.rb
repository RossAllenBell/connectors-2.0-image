require 'sinatra/base'
require 'elastic-apm'
require 'elastic-enterprise-search'

require './config'

class Connector < Sinatra::Base
  use ElasticAPM::Middleware

  SOURCE_NAME = 'Test Custom Source Ruby'

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

    content_source_id = client.list_content_sources.body.fetch('results').detect do |source|
      source.fetch('name') == SOURCE_NAME
    end&.fetch('id')

    if content_source_id.nil?
      content_source_id = client.create_content_source(name: SOURCE_NAME).body.fetch('id')
    end

    documents = [
      { id: 'e68fbc2688f1', title: 'Frankenstein; Or, The Modern Prometheus', author: 'Mary Wollstonecraft Shelley' },
      { id: '0682bb06af1a', title: 'Jungle Tales', author: 'Horacio Quiroga' },
      { id: '75015d85370d', title: 'Lenguas de diamante', author: 'Juana de Ibarbourou' },
      { id: 'c535e226aee3', title: 'Metamorphosis', author: 'Franz Kafka' },
    ]

    client.index_documents(content_source_id, documents: documents)

    'Consider it done.'
  end
end
