class CreateIdentities < ActiveRecord::Migration
  def change
    create_table :identities do |t|
      t.uuid :user_id
      t.string :provider
      t.string :uid

      t.timestamps
    end
  end
end