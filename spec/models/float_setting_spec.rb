require 'rails_helper'

RSpec.describe FloatSetting do
  before(:each){ 
    @setting = create :float_setting 
  }
  let(:form_field){ :string }
  let(:value){ 8 }
  let(:default){ 1.1 }

  it_behaves_like 'setting'

  it "has a float as value" do
    @setting.value = default
    expect(@setting.value).to eq 1.1
  end

  describe "validation" do
    ['abc', -10.0].each do |value|
      it "is not valid with a value of #{value}" do
        @setting.value = value
        expect(@setting).not_to be_valid
      end
      
    end

    [0, 1, 2.34].each do |value|
      it "is valid with a value of #{value}" do
        @setting.value = value
        expect(@setting).to be_valid
      end
    end
  end

  describe "form_field_partial" do
    it "is string_with_unit_field if the unit is set" do
      @setting.unit = 'foo'
      expect(@setting.form_field_partial).to eq 'settings/string_with_unit_field'
    end
  end
end
