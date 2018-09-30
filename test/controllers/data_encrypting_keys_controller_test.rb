require 'test_helper'

class DataEncryptingKeysControllerTest < ActionController::TestCase
  test ".rotate" do
    assert_difference "EncryptingKeyRotationWorker.jobs.size" do
      post :rotate
    end

    assert_response :success
    EncryptingKeyRotationWorker.clear
  end

  test ".rotate_status" do
    get :rotate_status
    assert_response :success
    assert_match 'No key rotation queued or in progress', @response.body
  end
end
