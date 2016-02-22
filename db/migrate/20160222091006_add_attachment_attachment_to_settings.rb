class AddAttachmentAttachmentToSettings < ActiveRecord::Migration
  def self.up
    change_table :settings do |t|
      t.attachment :attachment
    end
  end

  def self.down
    remove_attachment :settings, :attachment
  end
end
