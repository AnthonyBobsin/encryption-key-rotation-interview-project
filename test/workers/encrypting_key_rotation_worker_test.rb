require 'test_helper'

class EncryptingKeyRotationWorkerTest < ActiveSupport::TestCase
  class MockRotationService
    def rotate_all
      :success
    end
  end

  setup do
    @status_srv = MockWorkerStatusService.new
    @subject = EncryptingKeyRotationWorker.new(
      rotation_service: MockRotationService.new,
      status_service: @status_srv)
  end

  test ".perform" do
    # when worker is locked
    @status_srv.lock!
    success, result = @subject.perform

    # it does not invoke service
    assert_not success
    assert_match result, EncryptingKeyRotationWorker::Errors::IN_PROGRESS_ERROR

    # when worker is unlocked
    @status_srv.unlock!
    success, result = @subject.perform

    # it does invoke service
    assert success
    assert result == :success
  end
end
