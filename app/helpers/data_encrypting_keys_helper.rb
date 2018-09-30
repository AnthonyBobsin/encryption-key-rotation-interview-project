module DataEncryptingKeysHelper
  STATUS = SidekiqWorkerStatusService::Status
  STATUS_MESSAGE_MAP = {
    STATUS::WAITING => 'No key rotation queued or in progress'.freeze,
    STATUS::QUEUED => 'Key rotation has been queued'.freeze,
    STATUS::RUNNING => 'Key rotation is in progress'.freeze
  }

  def message_for_status(worker_status)
    STATUS_MESSAGE_MAP[worker_status]
  end
end
