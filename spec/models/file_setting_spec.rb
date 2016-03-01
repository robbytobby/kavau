require 'rails_helper'

RSpec.describe FileSetting do
  before(:each){ 
    @setting = create :file_setting 
    @form_field_partial = "settings/file_setting_field"
  }
  let(:form_field){ :string }
  let(:value){ nil }
  let(:default){ nil }

  it_behaves_like 'setting'

  it "returns an array of accepted types" do
    @setting.accepted_types = 'a, b, c'
    expect(@setting.accepted_types).to eq %w(a b c)
  end

  context "with an attachment" do
    before(:all) do
      @png = File.open "#{Rails.root}/spec/support/templates/logo.png"
      @pdf = File.open "#{Rails.root}/spec/support/templates/first_page.pdf"
    end

    it "validates the content type" do
      @setting.accepted_types = 'image/png, image/jpeg'

      @setting.attachment = @png
      expect(@setting).to be_valid

      @setting.attachment = @pdf
      expect(@setting).not_to be_valid
    end

    it "has the attachment path as value" do
      expect(@setting.value).to be_nil
      @setting.accepted_types = 'image/png, image/jpeg'
      @setting.attachment = @png
      dir = "#{Rails.root}/public/system/file_settings/attachments/"
      expect(@setting.value).to match(%r(#{dir}.*/logo.png))
    end
    
    it "destroy just deletes the attachment" do
      @setting.accepted_types = 'image/png, image/jpeg'
      @setting.attachment = @png
      @setting.save
      expect(@setting.attachment?).to be_truthy
      @setting.destroy
      expect(@setting.attachment?).to be_falsy
    end
  end
end


