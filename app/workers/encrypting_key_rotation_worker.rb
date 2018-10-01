class EncryptingKeyRotationWorker
  include Sidekiq::Worker

  def initialize(
      rotation_service: StringEncryptingKeyRotationService,
      status_service: SidekiqWorkerStatusService.new(self.class))
    @rotation_service = rotation_service
    @status_service = status_service
  end

  def perform
    unless @status_service.lock_available?
      logger.warn Errors::IN_PROGRESS_ERROR
      return [false, Errors::IN_PROGRESS_ERROR]
    end

    @status_service.lock!
    result = @rotation_service.rotate_all
    @status_service.unlock!

    [true, result]
  end

  private

  def being_performed?
    @status_service.lock_available?
  end

  module Errors
    IN_PROGRESS_ERROR = "Worker is already performing this task."
  end
end
