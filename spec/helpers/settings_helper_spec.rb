require 'rails_helper'

RSpec.describe SettingsHelper, type: :helper do
  it "group_information" do
    expect(I18n).to receive(:t).with('settings.help.category.group').and_return('Help')
    expect(helper.group_information('Category', 'Group')).to eq(
      {category: 'Category', group: 'Group', help: 'Help'}
    )
  end
end
