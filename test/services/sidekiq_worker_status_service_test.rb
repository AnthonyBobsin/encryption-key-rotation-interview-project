require 'test_helper'

class SidekiqWorkerStatusServiceTest < ActiveSupport::TestCase
  Status = SidekiqWorkerStatusService::Status

  setup do
    @redis_client = MockRedisClient.new
    @subject = SidekiqWorkerStatusService.new(MockWorker, redis_client: @redis_client)
  end

  test ".status" do
    # QUEUED
    MockWorker.job_size = 1
    @redis_client.get_response = nil
    assert @subject.status == Status::QUEUED

    # WAITING
    MockWorker.job_size = 0
    @redis_client.get_response = nil
    assert @subject.status == Status::WAITING

    # RUNNING
    @redis_client.get_response = "true"
    assert @subject.status == Status::RUNNING
  end

  test ".queued_params?" do
    # when queued jobs exist
    MockWorker.job_size = 2
    assert @subject.queued_params?

    # when no queued jobs exist
    MockWorker.job_size = 0
    assert_not @subject.queued_params?
  end

  test ".lock_available?" do
    # when available
    @redis_client.get_response = nil
    assert @subject.lock_available?

    # when not available
    @redis_client.get_response = "true"
    assert_not @subject.lock_available?
  end
end