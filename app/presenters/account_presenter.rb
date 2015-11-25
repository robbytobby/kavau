class AccountPresenter < BasePresenter
  def owner
    @model.owner.blank? ? AddressPresenter.new(@model.address, @view).full_name : @model.owner
  end

  def iban
    IBANTools::IBAN.new(@model.iban).prettify
  end

  def disburses
    payments.where(sign: -1).sum(:amount)
  end

  def deposits
    payments.where(sign: 1).sum(:amount)
  end

  def confirmation_label
    [
      I18n.t('confirmation_label.account'),
      I18n.t("confirmation_label.of.#{@model.address.type.underscore}"),
      owner,
      I18n.t('confirmation_label.with_iban'),
      iban
    ].join(' ')
  end

  def default
    return unless @model.default
    h.content_tag :span, nil, class: 'with_help glyphicon glyphicon-asterisk', title: Account.human_attribute_name(:default)
  end
end
