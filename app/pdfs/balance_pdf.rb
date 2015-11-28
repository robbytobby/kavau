class BalancePdf < ApplicationPdf
  def initialize(balance)
    @balance = balance
    super @balance.credit_agreement.account.address, @balance.creditor
  end
  
  private
  def content
    move_cursor_to 16.cm
    balance_heading
    move_down 20
    balance_table
    annotations
  end

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
      @balance.credit_agreement.id
    ].join(' ')
  end

  def balance_year
    [I18n.t(@balance.class.to_s.underscore, scope: 'pdf.balance'), @balance.date.year].join(' ')
  end

  def balance_table
    table (table_header + table_content), table_options do |table|
      table.columns(2..4).align = :right
      table.row(1).font_style = :bold
      table.row(-1).font_style = :bold
      table.row(-1).borders = [:top]
      table.row(1).border_width = 5 * style.line_width
      table.row(-1).border_width = 5 * style.line_width
    end
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

  #layout
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
