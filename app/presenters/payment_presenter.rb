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
end
