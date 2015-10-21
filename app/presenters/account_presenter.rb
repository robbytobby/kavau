class AccountPresenter < BasePresenter
  def owner
    @model.owner.blank? ? AddressPresenter.new(@model.address, @view).full_name : @model.owner
  end
end

