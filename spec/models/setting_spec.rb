require 'rails_helper'

RSpec.describe Setting, type: :model do
  before(:each){ reset_config }
  after(:all){ reset_config }

  it "the class updates the config" do
    create :string_setting, category: 'pdf', group: 'content', name: 'saldo_information', value: 'FooBar'
    create :array_setting, category: 'exception_notification', group: 'email', name: 'exception_recipients', value: 'test@test.org'
    create :string_setting, category: 'mailer', group: 'smtp_settings', name: 'address', value: 'TEST'
    Setting.update_config
    
    expect(Setting.kavau.pdf).to eq({:content=>{:saldo_information=>"FooBar"}})
    expect(Setting.kavau.mailer).to eq({:smtp_settings=>{:address=>"TEST"}})
    expect(Setting.kavau.exception_notification).to eq({:email=>{:exception_recipients=>"test@test.org"}})
  end

  it "uptdates the config from Settings if a Setting is saved" do
    expect(Setting.kavau.pdf[:content][:saldo_information]).to eq('additional information')
    s = create :string_setting, category: 'pdf', group: 'content', name: 'saldo_information', value: 'FooBar'
    expect(Setting.kavau.pdf[:content][:saldo_information]).to eq('FooBar')
    s.update_attributes(value: 'Baz')
    expect(Setting.kavau.pdf[:content][:saldo_information]).to eq('Baz')
  end

  describe "exception_notification settings are updated" do
    let(:em_config){ ->{ExceptionNotifier.class_variable_get('@@notifiers')} }
    let(:em_setting){ ->(key){ em_config.call[:email].options[key] } }

    it "updates the recipients" do
      s = create :array_setting, category: 'exception_notification', group: 'email', name: 'exception_recipients', value: 'test@test.org'
      expect(em_setting[:exception_recipients]).to eq 'test@test.org'
      s.update_attributes(value: "test@test.org, bla@blub.com")
      expect(em_setting[:exception_recipients]).to eq 'test@test.org, bla@blub.com'
      s.update_attributes(value: nil)
      expect(em_setting[:exception_recipients]).to eq nil
    end

    it "updates the sender" do
      s = create :string_setting, category: 'exception_notification', group: 'email', name: 'sender_address', value: 'test@test.org'
      expect(em_setting[:sender_address]).to eq 'test@test.org'
      s.update_attributes(value: "bla@blub.com")
      expect(em_setting[:sender_address]).to eq 'bla@blub.com'
      s.update_attributes(value: nil)
      expect(em_setting[:sender_address]).to eq nil
    end

    it "updates the prefix" do
      s = create :string_setting, category: 'exception_notification', group: 'email', name: 'email_prefix', value: 'TEST'
      expect(em_setting[:email_prefix]).to eq 'TEST'
      s.update_attributes(value: nil)
      expect(em_setting[:sender_address]).to eq "\"Exception Notifier\" <exception.notifier@example.com>"
    end
  end

  describe "it updates the smpt_settings" do
    let(:mailer_config){ ->{ActionMailer::Base.smtp_settings} }
    let(:mailer_setting){ ->(key){ mailer_config.call[key] } }

    it "updates the server address" do
      s = create :string_setting, category: 'mailer', group: 'smtp_settings', name: 'address', value: 'TEST'
      expect(mailer_setting[:address]).to eq 'TEST'
      s.update_attributes(value: 'localhost')
      expect(mailer_setting[:address]).to eq 'localhost'
    end

    it "updates the port" do
      s = create :integer_setting, category: 'mailer', group: 'smtp_settings', name: 'port', value: 22
      expect(mailer_setting[:port]).to eq 22
      s.update_attributes(value: 53)
      expect(mailer_setting[:port]).to eq 53
      s.update_attributes(value: nil)
      expect(mailer_setting[:port]).to eq nil
    end
    
    it "updates the authentication_method" do
      s = create :string_setting, category: 'mailer', group: 'smtp_settings', name: 'authentication', value: 'plain'
      expect(mailer_setting[:authentication]).to eq 'plain'
      s.update_attributes(value: 'login')
      expect(mailer_setting[:authentication]).to eq 'login'
      s.update_attributes(value: nil)
      expect(mailer_setting[:authentication]).to eq nil
    end

    it "updates the tls start setting" do
      s = create :boolean_setting, category: 'mailer', group: 'smtp_settings', name: 'enable_starttls_auto', value: 'true'
      expect(mailer_setting[:enable_starttls_auto]).to eq true
      s.update_attributes(value: 'false')
      expect(mailer_setting[:enable_starttls_auto]).to eq false
    end

    it "update the user_name" do
      s = create :string_setting, category: 'mailer', group: 'smtp_settings', name: 'user_name', value: 'test'
      expect(mailer_setting[:user_name]).to eq 'test'
      s.update_attributes(value: 'test@test.org')
      expect(mailer_setting[:user_name]).to eq 'test@test.org'
      s.update_attributes(value: nil)
      expect(mailer_setting[:user_name]).to eq nil
    end

    it "updates the password" do
      s = create :string_setting, category: 'mailer', group: 'smtp_settings', name: 'password', value: 'test'
      expect(mailer_setting[:password]).to eq 'test'
      s.update_attributes(value: 'FooBar')
      expect(mailer_setting[:password]).to eq 'FooBar'
      s.update_attributes(value: nil)
      expect(mailer_setting[:password]).to eq nil
    end
  end

end
