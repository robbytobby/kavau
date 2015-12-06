class LetterPdf < ApplicationPdf
  def initialize(creditor, letter)
    @letter = letter
    @pdf_letter = PdfLetter.new(@letter, self)
    super ProjectAddress.where(legal_form: 'registered_society').first, creditor
  end

  private
  def content
    @pdf_letter.content
  end
end
