class EncryptingKeyRotationWorker
  include Sidekiq::Worker

  def perform
    unless worker_status.lock_available?
      logger.warn Errors::IN_PROGRESS_ERROR
      return [false, Errors::IN_PROGRESS_ERROR]
    end

    worker_status.lock!
    result = EncryptingKeyRotationService.rotate_all
    worker_status.unlock!

    [true, result]
  end

  private

  def being_performed?
    worker_status.lock_available?
  end

  def worker_status
    @worker_status ||= SidekiqWorkerStatusService.new(self.class)
  end

  module Errors
    IN_PROGRESS_ERROR = "Worker is already performing this task."
    UNKNOWN_ERROR = "Failed to rotate all Encrypting Keys."
  end
end
