require 'rails_helper'

RSpec.describe IntegerSetting do
  before(:each){ 
    @setting = create :integer_setting 
  }
  let(:form_field){ :string }
  let(:value){ 8 }
  let(:default){ 2 }

  it_behaves_like 'setting'

  it "has a integer as value" do
    @setting.value = default
    expect(@setting.value).to be_a(Integer)
  end

  describe "validation" do
    ['abc', -1, 1.2].each do |value|
      it "is not valid with a value of #{value}" do
        @setting.value = value
        expect(@setting).not_to be_valid
      end
      
    end

    [ 0, 1, 234].each do |value|
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

