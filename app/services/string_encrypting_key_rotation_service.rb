
class StringEncryptingKeyRotationService < EncryptingKeyRotationService
  def rotate(encrypted, new_key = DataEncryptingKey.generate!)
    value = encrypted.value

    encrypted.data_encrypting_key = new_key
    encrypted.value = value

    encrypted.save! ? encrypted : (raise StandardError, encrypted.errors)
  end

  protected

  def encrypted_objects_for_key(key)
    EncryptedString.where(data_encrypting_key_id: key.id)
  end

end