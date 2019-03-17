class AddSettingForDeviseSender < ActiveRecord::Migration[4.2]
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
    Setting.find_by(group: 'devise').try(:delete)
  end
end
