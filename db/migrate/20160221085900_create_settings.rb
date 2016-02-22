class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.string :category, null: false
      t.string :group
      t.string :sub_group
      t.string :name, null: false
      t.text :value
      t.boolean :obligatory, default: false
      t.string :type
      t.string :unit
      t.string :default
      t.float :number

      t.timestamps null: false
    end

    defaults = [ 
      general: [
        {number: 0.1, name: 'project_name', obligatory: true, type: 'StringSetting'},
        {number: 0.2, name: 'website_url', type: 'StringSetting'}
      ],
      mailer: [
        {number: 1.1, group: 'smtp_settings', name: 'address', type: 'StringSetting', default: 'localhost'},
        {number: 1.2, group: 'smtp_settings', name: 'port', type: 'IntegerSetting', default: '25'},
        {number: 1.3, group: 'smtp_settings', name: 'authentication', type: 'StringSetting'},
        {number: 1.4, group: 'smtp_settings', name: 'enable_starttls_auto', type: 'BooleanSetting'},
        {number: 1.5, group: 'smtp_settings', name: 'user_name', type: 'StringSetting'},
        {number: 1.6, group: 'smtp_settings', name: 'password', type: 'StringSetting'},
        {number: 3.1, group: 'exception_mailer', sub_group: 'email', name: 'email_prefix', type: 'StringSetting'},
        {number: 3.2, group: 'exception_mailer', sub_group: 'email', name: 'sender_address', type: 'StringSetting'},
        {number: 3.3, group: 'exception_mailer', sub_group: 'email', name: 'exception_recipients', type: 'ArraySetting'}
      ],
      letter: [
        {number: 5.1, group: 'layout', name: 'top-margin'    , type: 'FloatSetting', obligatory: 'true', unit: 'cm', default: '2'},
        {number: 5.2, group: 'layout', name: 'bottom-margin', type: 'FloatSetting', obligatory: 'true', unit: 'cm', default: '3.5'},
        {number: 5.3, group: 'layout', name: 'left-margin'   , type: 'FloatSetting', obligatory: 'true', unit: 'cm', default: '2'},
        {number: 5.4, group: 'layout', name: 'right-margin'  , type: 'FloatSetting', obligatory: 'true', unit: 'cm', default: '2'},
        {number: 5.5, group: 'layout', name: 'color1', type: 'StringSetting'},
        {number: 5.6, group: 'layout', name: 'color2', type: 'StringSetting'},
        {number: 5.7, group: 'layout', name: 'logo', type: 'FileSetting' },
        {number: 5.8, group: 'layout', name: 'watermark', type: 'FileSetting'},
        {number: 5.9, group: 'layout', name: 'first_page_template', type: 'FileSetting'},
        {number: 6.0, group: 'layout', name: 'following_page_template', type: 'FileSetting'},
        {number: 8.1, group: 'custom_font', name: 'font_name', type: 'StringSetting'},
        {number: 8.1, group: 'custom_font', name: 'normal', type: 'FileSetting'},
        {number: 8.1, group: 'custom_font', name: 'italic', type: 'FileSetting'},
        {number: 8.1, group: 'custom_font', name: 'bold', type: 'FileSetting'},
        {number: 8.1, group: 'custom_font', name: 'bold_italic', type: 'FileSetting'},
        {number: 10.1, group: 'content', name: 'saldo_information', type: 'TextSetting'}
      ]
    ]

    puts defaults.class.to_s
    defaults.each do |hash|
      hash.each do |category, settings|
        settings.each do |setting|
          Setting.new(setting.merge(category: category)).save(validate: false)
        end
      end
    end
  end
end
