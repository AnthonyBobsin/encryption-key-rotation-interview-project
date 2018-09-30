require 'sidekiq/api'

class SidekiqWorkerStatusService
  module Status
    WAITING = 'WAITING'.freeze
    QUEUED = 'QUEUED'.freeze
    RUNNING = 'RUNNING'.freeze
  end
  QUEUE = 'queue'
  DEFAULT_WORKER_RUNNING_TIME = 60 # seconds

  def initialize(worker_klass, redis_client: Redis.current)
    @worker_klass = worker_klass
    @redis_client = redis_client
  end

  def status
    if lock_available?
      queued_params? ? Status::QUEUED : Status::WAITING
    else
      Status::RUNNING
    end
  end

  def queued_params?
    @worker_klass.jobs.size > 0
  end

  def lock_available?
    !redis.get(lock_key_for_worker)
  end

  def lock!
    redis.set(lock_key_for_worker, true, ex: DEFAULT_WORKER_RUNNING_TIME)
  end

  def unlock!
    redis.del(lock_key_for_worker)
  end

  private

  def lock_key_for_worker
    "WORKER_STATUS:GLOBAL_LOCK:#{@worker_klass.to_s.upcase}".freeze
  end

  def redis
    @redis_client
  end
end