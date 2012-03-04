class UsersAddNotificationFields < ActiveRecord::Migration
  def up
    add_column :users, :notify_email, :boolean
    add_column :users, :notify_fb,    :boolean

    User.update_all({:notify_email => true, :notify_fb => false})
  end

  def down
    remove_column :users, :notify_email
    remove_column :users, :notify_fb
  end
end
