class Pdf < ActiveRecord::Base
  belongs_to :letter
  belongs_to :creditor

  before_save :set_path, :create_file
  after_destroy :delete_file

  validates :creditor_id, :letter_id, presence: true
  validates_uniqueness_of :letter_id, scope: :creditor_id

  delegate :title, to: :letter

  def update_file
    create_file
  end

  private
  def create_file
    IO.binwrite path, file_content
  end

  def delete_file
    File.delete path
  end

  def file_content
    letter.to_pdf(creditor)
  end

  def set_path
    self.path = "#{directory}/#{file_name}"
  end

  def directory
    "public/system/#{directory_name}"
  end

  def directory_name
    I18n.t(letter.model_name.plural, scope: :directories, locale: I18n.default_locale)
  end

  def file_name
    "#{file_base_name}.pdf"
  end

  def file_base_name
    [year, file_name_prefix, creditor.name, creditor.first_name, creditor_id, letter_id].compact.join('_').gsub(/ /,'-')
  end

  def file_name_prefix
    return unless letter.is_a?(StandardLetter)
    #TODO: replace with_name
    letter.subject
  end

  def year
    letter.year || Date.today.year
  end
end
