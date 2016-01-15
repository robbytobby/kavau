class PdfBalance
  include BuildingBlock

  def initialize(balance, doc)
    @balance = balance
    @sender = PdfSender.new(@balance.project_address, doc)
    @document = doc
  end

  def content
    @sender.over_address_line
    recipient.address
    date_box
    move_cursor_to 15.cm
    balance_heading
    move_down 20
    balance_table
    annotations
    @sender.footer
  end

  private
  def annotations
    move_down(30)
    font_size(10) do
      text I18n.t('pdf.balance.interest_method', url: Settings.interest_method_url)
      payment_annotations
    end
  end

  def payment_annotations
    return unless @balance.payments.any?
    move_down(10)
    text I18n.t('pdf.balance.interest_presentation')
  end

  def balance_heading
    heading [credit_agreement_number, balance_year].join(' - ')
  end

  def credit_agreement_number
    [
      CreditAgreement.model_name.human, 
      CreditAgreement.human_attribute_name(:id), 
      CreditAgreementPresenter.new(@balance.credit_agreement, self).number
    ].join(' ')
  end

  def balance_year
    I18n.t(@balance.class.to_s.underscore, scope: 'pdf.balance', year: @balance.date.year)
  end

  def balance_table
    PdfTable.new(@document, table_data, table_options).draw
  end

  def table_data
    table_header + table_content
  end

  def table_options
    { right_align: 2..4, bold_rows: [1, -1], thick_border_rows: [1, -1] }
  end

  def table_header
    [ [
      Balance.human_attribute_name(:date),
      '',
      Balance.human_attribute_name(:interest_days),
      Balance.human_attribute_name(:interest_calculation),
      CreditAgreement.human_attribute_name(:amount)
    ] ]
  end

  def table_content
    table_items.map{ |item| item_fields(item) }
  end

  def table_items
    [
      @balance.send(:last_years_balance),
      @balance.payments,
      @balance.interest_spans, 
      @balance
    ].flatten.sort_by(&:date).map{|item| presenter(item) }
  end

  def presenter(item)
    presenter_class(item).new(item, self)
  end

  def presenter_class(item)
    "#{item.class}Presenter".constantize
  end

  def item_fields(item)
    [
      item.date,
      item.name,
      item.respond_to?(:interest_days) ? item.interest_days : '',
      item.respond_to?(:calculation) ? item.calculation : '',
      item.amount,
    ]
  end
end
