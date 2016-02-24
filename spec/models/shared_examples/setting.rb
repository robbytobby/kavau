RSpec.shared_examples "setting" do
  it "has the correct form_field set" do
    expect(@setting.form_field).to eq(form_field)
  end

  describe "setting the value" do
    it "sets the value if given" do
      @setting.value = value
      @setting.save
      expect(@setting.value).to eq value
    end

    it "sets the default value if the value given is blank" do
      @setting.update_attributes(default: default)
      @setting.value = nil
      @setting.save
      expect(@setting.value).to eq default
    end
  end

  describe "to_hash" do
    it "delivers a hash" do
      expect(@setting.to_hash).to eq({:Category =>{:SettingName=>@setting.value}})
    end

    it "the hash includes the group if given" do
      @setting.group = 'Group'
      expect(@setting.to_hash).to eq({:Category =>{:Group => {:SettingName=>@setting.value}}})
    end

    it "the hash includes the subgroup if given" do
      @setting.group = 'Group'
      @setting.sub_group = 'SubGroup'
      expect(@setting.to_hash).to eq({:Category =>{:Group => {:SubGroup => {:SettingName=>@setting.value}}}})
    end
  end
  
  it "destroy does not destroy but resets value to default" do
    @setting.default = default
    @setting.destroy
    expect(@setting.value).to eq(default)
  end

  it "has form_field_partial path defined" do
    expect(@setting.form_field_partial).to eq(@form_field_partial || 'settings/string_setting_field') 
  end
  
  it "has to partial path set" do
    expect(@setting.to_partial_path).to eq('settings/setting')
  end

  it "has a help" do
    #FIXME: bad spec. mirrors implementation
    @setting.group = 'Group'
    expect(I18n).to receive(:t).with('settings.help.category.group').and_return(true)
    @setting.help
  end
end

