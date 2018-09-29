
class EncryptingKeyRotationService
  class << self
    def rotate_all
      self.new.rotate_all
    end
  end

  def rotate_all
    new_key = DataEncryptingKey.generate!(primary: true)
    old_keys = DataEncryptingKey.where.not(id: new_key.id)

    old_keys.each do |old_key|
      # fetch encrypted strings in batches
      # start from 0 each time because we're emptying this dataset
      encrypted_strings_for_key(old_key).find_in_batches(start: 0) do |batch|
        # rotate each encrypted object with new key
        batch.each { |encrypted| rotate(encrypted, new_key) }
      end
    end

    # delete all keys not in-use
    old_keys.delete_all
    new_key
  end

  def rotate(encrypted, new_key = DataEncryptingKey.generate!)
    value = encrypted.value

    encrypted.data_encrypting_key = new_key
    encrypted.value = value

    encrypted.save! ? encrypted : (raise StandardError, encrypted.errors)
  end

  private

  def encrypted_strings_for_key(key)
    EncryptedString.where(data_encrypting_key_id: key.id)
  end
end