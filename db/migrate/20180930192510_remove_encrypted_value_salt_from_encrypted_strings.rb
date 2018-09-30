class RemoveEncryptedValueSaltFromEncryptedStrings < ActiveRecord::Migration
  def change
    remove_column :encrypted_strings, :encrypted_value_salt
  end
end
