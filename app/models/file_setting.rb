class FileSetting < Setting
  has_attached_file :attachment
  do_not_validate_attachment_file_type :attachment
  validate :accepted_content_type

  def accepted_content_type
    return if attachment_file_name == nil
    return if accepted_types.include?(attachment_content_type)
    errors.add(:attachment_content_type, :invalid, accepted_types: accepted_types.to_sentence)
  end

  def accepted_types
    self[:accepted_types].split(',').map(&:strip)
  end

  def value
    return nil unless attachment?
    attachment.path
  end

  def destroy
    self.attachment = nil
    save
  end

  def form_field_partial
    'settings/file_setting_field'
  end
end

