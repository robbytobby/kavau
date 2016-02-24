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
      expect(@setting.value).to be_truthy
    end

    it "is false" do
      @setting.value = 'false'
      expect(@setting.value).to be_falsy
    end
  end
end

