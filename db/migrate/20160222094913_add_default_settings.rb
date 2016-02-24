class AddDefaultSettings < ActiveRecord::Migration
  def up
    defaults.each do |hash|
      hash.each do |category, settings|
        settings.each do |setting|
          Setting.new(setting.merge(category: category)).save(validate: false)
        end
      end
    end
    Setting.all.each do |s|
      s.value = s.default
      s.save
    end
  end

  def down
    Setting.delete_all
  end

  def defaults
    [ 
      general: [
        {number:  0.1,                            name: 'project_name',            type: 'StringSetting', obligatory: true},
        {number:  0.2,                            name: 'website_url',             type: 'StringSetting'}
      ],
      mailer: [
        {number:  1.1,  group: 'smtp_settings',   name: 'address',                 type: 'StringSetting',  default: 'localhost'},
        {number:  1.2,  group: 'smtp_settings',   name: 'port',                    type: 'IntegerSetting', default: '25'},
        {number:  1.3,  group: 'smtp_settings',   name: 'authentication',          type: 'StringSetting'},
        {number:  1.4,  group: 'smtp_settings',   name: 'enable_starttls_auto',    type: 'BooleanSetting', default: true},
        {number:  1.5,  group: 'smtp_settings',   name: 'user_name',               type: 'StringSetting'},
        {number:  1.6,  group: 'smtp_settings',   name: 'password',                type: 'StringSetting'}
      ],
      exception_notification: [
        {number:  3.1,  group: 'email',           name: 'email_prefix',            type: 'StringSetting'},
        {number:  3.2,  group: 'email',           name: 'sender_address',          type: 'StringSetting'},
        {number:  3.3,  group: 'email',           name: 'exception_recipients',    type: 'ArraySetting'}
      ],
      pdf: [
        {number:  5.1,  group: 'margins',         name: 'top_margin',              type: 'FloatSetting', obligatory: 'true', unit: 'cm', default: '2'},
        {number:  5.2,  group: 'margins',         name: 'bottom_margin',           type: 'FloatSetting', obligatory: 'true', unit: 'cm', default: '3.5'},
        {number:  5.3,  group: 'margins',         name: 'left_margin',             type: 'FloatSetting', obligatory: 'true', unit: 'cm', default: '2'},
        {number:  5.4,  group: 'margins',         name: 'right_margin',            type: 'FloatSetting', obligatory: 'true', unit: 'cm', default: '2'},
        {number:  5.5,  group: 'colors',          name: 'color1',                  type: 'StringSetting', default: '009dc3'},
        {number:  5.6,  group: 'colors',          name: 'color2',                  type: 'StringSetting', default: 'f9b625'},
        {number:  5.65, group: 'colors',          name: 'color3',                  type: 'StringSetting', default: '7c7b7f'},
        {number:  5.7,  group: 'templates',       name: 'logo',                    type: 'FileSetting', accepted_types: 'image/png, image/jpeg' },
        {number:  5.8,  group: 'templates',       name: 'watermark',               type: 'FileSetting', accepted_types: 'image/png, image/jepg'},
        {number:  5.9,  group: 'templates',       name: 'first_page_template',     type: 'FileSetting', accepted_types: 'application/pdf'},
        {number:  6.0,  group: 'templates',       name: 'following_page_template', type: 'FileSetting', accepted_types: 'application/pdf'},
        {number:  8.2,  group: 'custom_font',     name: 'normal',                  type: 'FileSetting', accepted_types: "application/x-font-ttf"},
        {number:  8.3,  group: 'custom_font',     name: 'italic',                  type: 'FileSetting', accepted_types: "application/x-font-ttf"},
        {number:  8.4,  group: 'custom_font',     name: 'bold',                    type: 'FileSetting', accepted_types: "application/x-font-ttf"},
        {number:  8.5,  group: 'custom_font',     name: 'bold_italic',             type: 'FileSetting', accepted_types: "application/x-font-ttf"},
        {number: 10.1,  group: 'content',         name: 'saldo_information',       type: 'TextSetting'}
      ]
    ]
  end
end
