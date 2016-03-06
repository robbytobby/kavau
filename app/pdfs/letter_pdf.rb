class LetterPdf < ApplicationPdf
  include BuildingBlock

  def initialize(creditor, letter)
    @letter = letter
    @document = self
    super ProjectAddress.default, creditor
  end

  private
  def content
    subject
    salutation
    move_down 10
    main_content
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
