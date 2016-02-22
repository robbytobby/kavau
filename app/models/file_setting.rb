class FileSetting < Setting
  has_attached_file :attachment
  validates_attachment_content_type :attachment, content_type: ["image/jpeg", "image/png", "application/pdf", "application/x-font-ttf"]
  validate :accepted_content_type

  def accepted_content_type
    return if attachment_file_name == nil
    errors.add(:attachment, 'Buh') unless accepted_types.include?(attachment_content_type)
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

