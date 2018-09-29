module DataEncryptingKeysHelper
  STATUS_MESSAGE_MAP = {
    SidekiqWorkerStatusService::Status::WAITING => 'No key rotation queed or in progress'.freeze,
    SidekiqWorkerStatusService::Status::QUEUED => 'Key rotation has been queued'.freeze,
    SidekiqWorkerStatusService::Status::RUNNING => 'Key rotation is in progress'.freeze
  }

  def message_for_status(worker_status)
    STATUS_MESSAGE_MAP[worker_status]
  end
end
