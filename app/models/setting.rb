class Setting < ActiveRecord::Base
  after_save :set_letter_config

  def self.general
    where(category: 'general').to_hash[:general]
  end

  def self.mailer
    where(category: 'mailer').to_hash[:mailer]
  end

  def self.letter
    where(category: 'letter').to_hash[:letter]
  end

  def form_field
    :string
  end

  def value=(val)
    self[:value] = (val.blank? ? default : val)
  end

  def to_hash
    {category.to_sym => group_hash}
  end

  def destroy
    self.value = nil
    save
  end

  def form_field_partial
    return 'settings/string_setting_field' if unit.blank?
    'settings/string_with_unit_field'
  end

  def to_partial_path
    'settings/setting'
  end
  
  def help
    I18n.t [:settings, :help, category, group].compact.join('.')
  end

  private
  def self.to_hash
    all.inject({}){ |hash, setting| hash.deep_merge!(setting.to_hash) }
  end

  def name_value_hash
    {name.to_sym => value}
  end

  def sub_group_hash
    return name_value_hash if sub_group.blank?
    {sub_group.to_sym => name_value_hash}
  end

  def group_hash
    return sub_group_hash if group.blank?
    {group.to_sym => sub_group_hash}
  end

  def set_letter_config
    return unless category == 'letter'
    Rails.application.config.letter = Setting.letter
  end

end
