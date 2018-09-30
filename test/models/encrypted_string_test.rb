require 'test_helper'

class EncryptedStringTest < ActiveSupport::TestCase
  test '.encryption_encrypted_key' do
    primary_key = data_encrypting_keys(:primary)
    secondary_key = data_encrypting_keys(:secondary)

    # when model does not have a data_encrypting_key
    string = EncryptedString.create!(value: "Test One")
    assert string.encryption_encrypted_key == primary_key.encrypted_key

    # when model does have data_encrypting_key
    string = EncryptedString.create!(value: "Test Two", data_encrypting_key_id: secondary_key.id)
    assert string.encryption_encrypted_key == secondary_key.encrypted_key
  end
end
