class AccountPresenter < BasePresenter
  def owner
    @model.owner.blank? ? AddressPresenter.new(@model.address, @view).full_name : @model.owner
  end

  def iban
    IBANTools::IBAN.new(@model.iban).prettify
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
end
