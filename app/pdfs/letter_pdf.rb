class LetterPdf < ApplicationPdf
  include BuildingBlock

  def initialize(creditor, letter)
    @letter = letter
    @document = self
    super ProjectAddress.where(legal_form: 'registered_society').first, creditor
  end

  private
  def content
    sender.over_address_line
    recipient.address
    date_box
    move_cursor_to 15.cm
    subject
    salutation
    move_down 10
    main_content
    sender.footer
  end

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
