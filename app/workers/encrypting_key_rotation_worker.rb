class EncryptingKeyRotationWorker
  include Sidekiq::Worker

  def perform
    if worker_status.lock_available?
      logger.warn Errors::IN_PROGRESS_ERROR
      return [false, Errors::IN_PROGRESS_ERROR]
    end

    worker_status.lock!

    begin
      [true, EncryptingKeyRotationService.rotate_all]
    rescue => e
      logger.error Errors::UNKNOWN_ERROR
      logger.error e.message

      [false, e.message]
    ensure
      worker_status.unlock!
    end
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
