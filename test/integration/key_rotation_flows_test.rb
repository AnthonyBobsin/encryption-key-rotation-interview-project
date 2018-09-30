require 'test_helper'

class KeyRotationFlowsTest < ActionDispatch::IntegrationTest
  def cleanup
    # unlock our worker
    SidekiqWorkerStatusService.new(EncryptingKeyRotationWorker).unlock!
    EncryptingKeyRotationWorker.clear
  end

  setup do
    cleanup

    @old_key = DataEncryptingKey.generate!(primary: true)
    @encrypted_strings = 1000.times.map do |i|
      EncryptedString.create!(value: "Test String #{i}", data_encrypting_key_id: @old_key.id)
    end
  end

  teardown do
    cleanup
  end

  test "schedules and performs encrypting key rotation" do
    # queue rotation job
    post '/data_encrypting_keys/rotate'
    assert_response :success

    # check that rotation job is queued
    get '/data_encrypting_keys/rotate/status'
    assert_response :success

    expected_status = DataEncryptingKeysHelper::STATUS_MESSAGE_MAP[SidekiqWorkerStatusService::Status::QUEUED]
    assert_match expected_status, @response.body

    # trigger sidekiq worker to pull from queue
    EncryptingKeyRotationWorker.drain

    # check that rotation job is waiting (finished)
    get '/data_encrypting_keys/rotate/status'
    expected_status = DataEncryptingKeysHelper::STATUS_MESSAGE_MAP[SidekiqWorkerStatusService::Status::WAITING]
    assert_match expected_status, @response.body

    # ensure we updated encrypted key to primary and properly
    # updated all encrypted strings
    new_key = DataEncryptingKey.primary
    assert new_key.id != @old_key.id
    @encrypted_strings.each_with_index do |encrypted_string, i|
      encrypted_string.reload

      assert new_key.id == encrypted_string.data_encrypting_key_id
      assert "Test String #{i}" ==  encrypted_string.value
    end
  end
end
