require 'rails_helper'

RSpec.describe StringSetting do
  before(:each){ @setting = create :string_setting }
  let(:form_field){ :string }
  let(:value){ 'MyString' }
  let(:default){ 'Default' }

  it_behaves_like 'setting'

  describe "form_field" do
    it "is :passwords if the setting name is password" do
      @setting.name = 'password'
      expect(@setting.form_field).to eq :password
    end
  end
end
