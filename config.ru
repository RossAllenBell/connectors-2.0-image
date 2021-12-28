def config_yml
  @_config_yml ||= YAML.load(File.open('./config.yml'))
end

log = File.new('log/connector.log', 'a+')
$stdout.reopen(log)
$stderr.reopen(log)

# optionally to sync logs while the server is running
$stderr.sync = true
$stdout.sync = true

require './connector'

require 'elastic-apm'
if config_yml.dig('elastic', 'apm' 'enabled')
  ElasticAPM.start(
    app: Connector,
    server_url: config_yml.dig('elastic', 'apm' 'url'),
    secret_token: config_yml.dig('elastic', 'apm' 'secret_token'),
  )
end

run Connector

at_exit { ElasticAPM.stop }
