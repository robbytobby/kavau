require 'rails_helper'

RSpec.describe TextSetting do
  before(:each){ @setting = create :text_setting }
  let(:form_field){ :text }
  let(:value){ 'MyString' }
  let(:default){ 'Default' }

  it_behaves_like 'setting'
end
