class AddAttachmentAvatarToMyrecipes < ActiveRecord::Migration[5.2]
  def self.up
    change_table :myrecipes do |t|
      t.attachment :avatar
    end
  end

  def self.down
    remove_attachment :myrecipes, :avatar
  end
end
