class BalancePdf < ApplicationPdf
  
  private
  def setup_instance_variables
    super
  end
  
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
    return unless @record.payments.any?
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
      @record.credit_agreement.id
    ].join(' ')
  end

  def balance_year
    [I18n.t(@record.class.to_s.underscore, scope: 'pdf.balance'), @record.date.year].join(' ')
  end

  def balance_table
    table (table_header + table_content), table_options do |table|
      table.columns(2..4).align = :right
      table.row(1).font_style = :bold
      table.row(-1).font_style = :bold
      table.row(-1).borders = [:top]
      table.row(1).border_width = 5 * @line_width
      table.row(-1).border_width = 5 * @line_width
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
      @record.send(:last_years_balance),
      @record.payments,
      @record.interest_spans, 
      @record
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
      width: bounds.width,
      column_widths: default_column_widths 
    }
  end

  def cell_defaults
    { 
      size: 10, 
      borders: [:bottom], 
      border_width: @line_width,
      inline_format: true, 
      overflow: :shrink_to_fit
    }
  end

  def default_column_widths
    {}
  end
end
