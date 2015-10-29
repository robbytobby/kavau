class AccountPresenter < BasePresenter
  def owner
    @model.owner.blank? ? AddressPresenter.new(@model.address, @view).full_name : @model.owner
  end

  def iban
    IBANTools::IBAN.new(@model.iban).prettify
  end
end
