class PdfLetter
  include BuildingBlock

  def initialize(letter, doc)
    @letter = letter
    @document = doc
  end

  def content
    sender.over_address_line
    recipient.address
    date_box
    move_cursor_to 17.cm
    subject
    salutation
    move_down 10
    main_content
    sender.footer
  end

  private
  def salutation
    text I18n.t(salutation_key, scope: [:pdf, :salutation], name: recipient.full_name(:informal)) + ','
  end

  def subject
    return if @letter.subject.blank?
    text "<b>#{Letter.human_attribute_name(:subject)}:</b> #{@letter.subject}", inline_format: true
    move_down 20
  end

  def salutation_key
    recipient.model.salutation || recipient.model.legal_form
  end

  def main_content
    text @letter.content, inline_format: true
  end
end
  
