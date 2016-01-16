class PaymentPdf < ApplicationPdf
  include BuildingBlock
  #TODO spec

  def initialize(payment)
    @payment = payment
    @letter = PaymentLetter.first
    super @payment.credit_agreement.account.address, @payment.credit_agreement.creditor
  end

  private
  def content
    sender.over_address_line
    recipient.address
    date_box
    move_cursor_to 15.cm
    subject
    move_down 20
    salutation
    move_down 10
    main_content
    sender.footer
  end

  def subject
    return if @letter.subject.blank?
    text "<b>Betreff:</b> #{@letter.subject}", inline_format: true
  end

  def salutation
    text I18n.t(salutation_key, scope: [:pdf, :salutation], name: recipient.full_name(:informal)) + ','
  end

  def salutation_key
    recipient.model.salutation || recipient.model.legal_form
  end

  def main_content
    text processed_text
  end

  def processed_text
    @letter.content.
      gsub(/#BETRAG/, number_to_currency(@payment.amount)).
      gsub(/#DATUM/, I18n.l(@payment.date)).
      gsub(/#PROJEKT_?[ADGN]?/){|m| send(:declinated_project_name, m) }
  end

  def declinated_project_name(casus)
    casus = casus.gsub(/#PROJEKT_?([ADGN]?)/, '\1')
    I18n.t("pdf.project_name_with_article.#{@sender.legal_form}.#{casus_key(casus)}", name: @sender.full_name)
  end

  def casus_key(casus = 'N')
    {N: 'nominativ', G: 'genitiv', D: 'dativ', A: 'accusativ'}[casus.to_sym]
  end
end
