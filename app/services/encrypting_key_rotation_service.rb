
class EncryptingKeyRotationService
  class << self
    def rotate_all
      self.new.rotate_all
    end
  end

  # NOTE: This implementation aborts and reverts transaction
  #       once an encrypted object fails update. Depending
  #       on requirements of failures, we can modify this to
  #       continue and rotate the rest of the objects.
  def rotate_all
    # wrap in transaction to ensure our encrypted data integrity
    ActiveRecord::Base.transaction do
      new_key = DataEncryptingKey.generate!(primary: true)
      old_keys = DataEncryptingKey.where.not(id: new_key.id)

      old_keys.each do |old_key|
        # fetch encrypted strings in batches
        # start from 0 each time because we're emptying this dataset
        encrypted_objects_for_key(old_key).find_in_batches(start: 0) do |batch|
          # rotate each encrypted object with new key
          batch.each { |encrypted| rotate(encrypted, new_key) }
        end
      end

      # delete all keys not in-use
      old_keys.delete_all
      new_key
    end
  end

  def rotate(encrypted, new_key = DataEncryptingKey.generate!)
    raise NotImplementedError, "Implement this in a child class!"
  end

  protected

  def encrypted_objects_for_key(key)
    raise NotImplementedError, "Implement this in a child class!"
  end
end