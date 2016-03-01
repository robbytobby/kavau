class AddSettingForDeviseSender < ActiveRecord::Migration
  def up
    Setting.new(number: 2.1,
                category: 'mailer',
                group: 'devise',
                name: 'mailer_sender',
                type: 'StringSetting',
                obligatory: true
               ).save(validate: false)
  end

  def down
    Setting.find_by(group: 'devise').delete_all
  end
end
