class InterestCertificatePdf < ApplicationPdf
  private
  def content
    move_cursor_to 16.cm
    interest_certificate_heading
    move_down 10
    preamble
    move_down 10
    interest_rate_line
    interest_sum_line
    move_down 20
    thanks
  end

  def interest_certificate_heading
    heading I18n.t('pdf.interest_certificate.heading', year: @record.date.year)
  end

  def preamble
    text I18n.t('pdf.interest_certificate.text',
                creditor: @recipient.full_name(:pdf), 
                project_address: project_name_with_article,
                project_name: Settings.project_name)
  end

  def interest_rate_line
    heading I18n.t('pdf.interest_certificate.interest_rate',
                   rate: number_to_percentage(@record.interest_rate))
  end

  def interest_sum_line
    heading I18n.t('pdf.interest_certificate.interests_sum',
                   year: @record.date.year,
                   amount: number_to_currency(@record.interests_sum))
  end

  def thanks
    text I18n.t('pdf.interest_certificate.thanks')
    text @sender.full_name
  end

  def project_name_with_article
    I18n.t(@sender.model.legal_form, scope: 'pdf.interest_certificate.name_with_article', name: @sender.name)
  end

  
end
