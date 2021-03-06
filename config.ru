require './config'

log = File.new('log/connector.log', 'a+')
$stdout.reopen(log)
$stderr.reopen(log)

# optionally to sync logs while the server is running
$stderr.sync = true
$stdout.sync = true

require 'ecs_logging/middleware'
use EcsLogging::Middleware, $stdout
use EcsLogging::Middleware, $stderr

require './connector'

require 'elastic-apm'
if config_yml.dig('elastic', 'apm', 'enabled')
  ElasticAPM.start(
    app: Connector,
    server_url: config_yml.dig('elastic', 'apm', 'host'),
    secret_token: config_yml.dig('elastic', 'apm', 'secret_token'),
  )
end

run Connector

at_exit { ElasticAPM.stop }
