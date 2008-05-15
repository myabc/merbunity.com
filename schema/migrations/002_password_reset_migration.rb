class PasswordResetMigration < ActiveRecord::Migration
  
  def self.up
    add_column :people, :password_reset_key, :string 
  end
  
  def self.down
    remove_column :people, :password_reset_key
  end
  
end