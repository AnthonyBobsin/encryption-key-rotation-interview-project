require 'test_helper'

class StringEncryptingKeyRotationServiceTest < ActiveSupport::TestCase
  setup do
    @subject = StringEncryptingKeyRotationService.new
  end

  test ".rotate_all" do
    sample_string = EncryptedString.first
    old_value = sample_string.value
    old_encrypted_value = sample_string.encrypted_value

    new_key = @subject.rotate_all
    sample_string.reload

    new_value = sample_string.value
    new_encrypted_value = sample_string.encrypted_value

    # Ensure that the decrypted value hasn't changed from the old value
    assert old_value == new_value
    # Ensure that we encrypted the value differently
    assert old_encrypted_value != new_encrypted_value

    # Ensure that all encrypted strings are using our newly generated key
    assert EncryptedString.count == EncryptedString.where(data_encrypting_key_id: new_key.id).count

    # Ensure that all values are still decryptable
    assert_nothing_raised do
      EncryptedString.all.map(&:value)
    end
  end

  test ".rotate" do
    sample_string = EncryptedString.first
    old_value = sample_string.value
    old_encrypted_value = sample_string.encrypted_value

    new_key = DataEncryptingKey.generate!
    new_string = @subject.rotate(sample_string, new_key)
    new_value = new_string.value
    new_encrypted_value = new_string.encrypted_value

    # Ensure that the decrypted value hasn't changed from the old value
    assert old_value == new_value
    # Ensure that we encrypted the value differently
    assert old_encrypted_value != new_encrypted_value
  end
end