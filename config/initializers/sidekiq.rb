redis_conf = YAML.load_file("#{File.dirname(__FILE__)}/../redis.yml")

Sidekiq.configure_server do |config|
  config.redis = redis_conf
end

Sidekiq.configure_client do |config|
  config.redis = redis_conf
end
