class PaymentPresenter < BasePresenter
  include ActionView::Helpers::NumberHelper

  def date
    I18n.l @model.date
  end

  def amount
    number_to_currency(@model.sign * @model.amount)
  end

  def confirmation_label
    [
      I18n.t("confirmation_label.#{@model.type.underscore}"),
      date,
      I18n.t('confirmation_label.with_amount'),
      number_to_currency(@model.amount),
    ].join(' ')
  end

  def credit_agreement_number
    credit_agreement.number
  end

  def creditor_name
    CreditorPresenter.new(credit_agreement.creditor, @view).full_name
  end

  def account_name
    credit_agreement.account.name
  end

  def type
    @model.type.constantize.model_name.human
  end

end
