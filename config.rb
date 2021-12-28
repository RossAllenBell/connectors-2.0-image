require 'yaml'

def config_yml
  @_config_yml ||= YAML.load(File.open('./config.yml'))
end
