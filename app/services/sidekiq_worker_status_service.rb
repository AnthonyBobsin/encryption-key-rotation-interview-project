require 'sidekiq/api'

class SidekiqWorkerStatusService
  module Status
    WAITING = 'WAITING'.freeze
    QUEUED = 'QUEUED'.freeze
    RUNNING = 'RUNNING'.freeze
  end
  QUEUE = 'queue'

  def initialize(worker_klass)
    @worker_klass = worker_klass
  end

  def status
    if lock_available?
      queued_params? ? QUEUED : WAITING
    else
      RUNNING
    end
  end

  def queued_params?
    Sidekiq::Queue.new(@worker_klass.sidekiq_options[QUEUE]).size > 0
  end

  def lock_available?
    !!redis.get(lock_key_for_worker)
  end

  def lock!
    redis.set(lock_key_for_worker, true)
  end

  def unlock!
    redis.del(lock_key_for_worker)
  end

  private

  def lock_key_for_worker
    "WORKER_STATUS:GLOBAL_LOCK:#{@worker_klass.to_s.upcase}".freeze
  end

  def redis
    @redis ||= Redis.current
  end
end