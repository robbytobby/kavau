require 'rails_helper'

RSpec.describe BooleanSetting do
  before(:each){ 
    @setting = create :boolean_setting 
    @form_field_partial = "settings/boolean_setting_field"
  }
  let(:form_field){ :string }
  let(:value){ true }
  let(:default){ false }

  it_behaves_like 'setting'

  describe "its value" do
    it "is true" do
      @setting.value = 'true'
      @setting.save
      expect(@setting.reload.value).to eq true
    end

    it "is false" do
      @setting.value = 'true'
      @setting.save
      @setting.value = 'false'
      @setting.save
      expect(@setting.reload.value).to eq false
      @setting.value = false
      @setting.save
      expect(@setting.reload.value).to eq false
    end

    it "is false by default" do
      @setting.value = nil 
      @setting.save
      expect(@setting.reload.value).to eq false
    end
  end
end

