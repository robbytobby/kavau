class PdfInterestCertificate
  include BuildingBlock
  include I18nKeyHelper

  def initialize(project_address, balances, doc)
    @balances = balances
    @document = doc
    @sender = PdfSender.new(project_address, doc)
    @year = balances.first.date.year
  end

  def content
    @sender.over_address_line
    recipient.address
    date_box
    move_cursor_to 16.cm
    interest_certificate_heading
    move_down 10
    preamble
    move_down 10
    interests_table
    move_down 20
    thanks
    @sender.footer
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
      I18n.t('pdf.interest_certificate.text4', name: Settings.project_name)
    ]
  end

  def thanks
    text I18n.t('pdf.interest_certificate.thanks')
    text @sender.full_name
  end

  def interests_table
    table (table_header + table_content + table_sum), table_options do |table|
      style.standard_table(table, right_align: 1..2, bold_rows: [0, -1], thick_border_rows: [0, -1])
    end
  end

  def table_header
    [ [
      [CreditAgreement.model_name.human, CreditAgreement.human_attribute_name(:id)].join('-'),
      CreditAgreement.human_attribute_name(:interest_rate),
      I18n.t('pdf.interest_certificate.interests_year_amount', year: @year)
    ] ]
  end

  def table_content
    @balances.sort_by{|b| b.credit_agreement.id}.map{ |balance|
      [
        balance.credit_agreement.id,
        I18n.t('pdf.interest_certificate.interest_rate', rate: number_to_percentage(balance.interest_rate)),
        number_to_currency(balance.interests_sum)
      ]
    }
  end

  def table_sum
    return [] if @balances.one?
    [ [ '', '', I18n.t('pdf.interest_certificate.sum', amount: number_to_currency(@balances.sum(&:interests_sum))) ]]
  end

  def table_options
    { 
      cell_style: cell_defaults,
      width: bounds.width
    }
  end

  def cell_defaults
    { 
      size: 10, 
      borders: [:bottom], 
      border_width: style.line_width,
      inline_format: true, 
      overflow: :shrink_to_fit
    }
  end
end
