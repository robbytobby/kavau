require 'rails_helper'

RSpec.describe ArraySetting do
  before(:each){ @setting = create :array_setting }
  let(:form_field){ :string }
  let(:value){ 'MyString' }
  let(:default){ '1,2,3' }

  it_behaves_like 'setting'

  it "can return an array" do
    @setting.value = default
    expect(@setting.to_a).to eq(['1','2','3'])
  end
end

