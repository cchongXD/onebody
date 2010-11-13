class AddFacebookColumnsToPeople < ActiveRecord::Migration
  def self.up
    change_table :people do |t|
      t.string :facebook_id, :limit => 50
      t.boolean :facebook_imported, :default => false
    end
  end

  def self.down
    change_table :people do |t|
      t.remove :facebook_id
      t.remove :facebook_imported
    end
  end
end
