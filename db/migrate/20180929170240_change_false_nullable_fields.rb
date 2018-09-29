class ChangeFalseNullableFields < ActiveRecord::Migration
  def change
    # Improve null-safety for columns that should never have null values

    # data_encrypting_keys
    change_column :data_encrypting_keys, :encrypted_key, :string, null: false
    change_column :data_encrypting_keys, :primary, :boolean, null: false, default: false

    # encrypted_strings
    change_column :encrypted_strings, :encrypted_value, :string, null: false
    change_column :encrypted_strings, :encrypted_value_iv, :string, null: false
    change_column :encrypted_strings, :encrypted_value_salt, :string, null: false
    change_column :encrypted_strings, :data_encrypting_key_id, :integer, null: false
  end
end
