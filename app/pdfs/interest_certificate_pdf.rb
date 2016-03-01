class InterestCertificatePdf < ApplicationPdf
  include BuildingBlock
  include I18nKeyHelper

  def initialize(balances)
    @balances = balances
    @project_address = balances.first.project_address
    @creditor = balances.first.creditor
    @year = balances.first.date.year
    super @project_address, @creditor
  end

  def content
    interest_certificate_heading
    move_down 10
    preamble
    move_down 10
    interests_table
    move_down 20
    thanks
  end

  private
  def interest_certificate_heading
    heading I18n.t('pdf.interest_certificate.heading', year: @year)
  end

  def preamble
    text preamble_data.join(' ')
  end

  def preamble_data
    [
      I18n.t(key_with_legal_form(recipient.model),
             scope: 'pdf.interest_certificate.text1', 
             name: recipient.full_name(:pdf)),
      I18n.t(@sender.legal_form, scope: 'pdf.interest_certificate.text2', name: @sender.full_name),
      I18n.t('pdf.interest_certificate.text3', count: @balances.count),
      I18n.t('pdf.interest_certificate.text4', name: Setting.kavau.general[:project_name])
    ]
  end

  def thanks
    text I18n.t('pdf.interest_certificate.thanks')
    text @sender.full_name
  end

  def interests_table
    PdfTable.new(self, table_data, table_options).draw
  end

  def table_data
    table_header + table_content + table_sum
  end

  def table_options
    { right_align: 1..2, bold_rows: [0, -1], thick_border_rows: [0, -1] }
  end

  def table_header
    [ [
      [CreditAgreement.model_name.human, CreditAgreement.human_attribute_name(:id)].join('-'),
      I18n.t('pdf.interest_certificate.interests_year_amount', year: @year)
    ] ]
  end

  def table_content
    @balances.sort_by{|b| b.credit_agreement.id}.reject{|b| b.credit_agreement.interest_rate == 0 }.map{ |balance|
      [
        CreditAgreementPresenter.new(balance.credit_agreement, self).number,
        number_to_currency(balance.interests_sum)
      ]
    }
  end

  def table_sum
    return [] if @balances.one?
    [ [ '', I18n.t('pdf.interest_certificate.sum', amount: number_to_currency(@balances.sum(&:interests_sum))) ]]
  end
end
