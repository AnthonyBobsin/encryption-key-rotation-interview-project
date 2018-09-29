class DataEncryptingKeysController < ApplicationController
  include DataEncryptingKeysHelper

  before_action :set_worker_status

  def rotate
    if @worker_status.status == WAITING
      render json: EncryptingKeyRotationWorker.perform_async
    else
      render json: { message: Errors::ROTATION_WORKER_BUSY },
             status: :unprocessable_entity
    end
  end

  def rotate_status
    render json: { message: message_for_status(@worker_status.status) }
  end

  private

  def set_worker_status
    @worker_status = SidekiqWorkerStatusService.new(EncryptingKeyRotationWorker)
  end

  module Errors
    ROTATION_WORKER_BUSY = 'Key rotation worker is busy and cannot be triggered at this moment'.freeze
  end
end
