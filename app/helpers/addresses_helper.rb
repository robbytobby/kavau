module AddressesHelper
  def new_model_path
    send("new_#{@type.underscore}_path")
  end

  def edit_address_path(address)
    send("edit_#{address.type.underscore}_path", address)
  end

  def cancel_path(address)
    if address.creditor?
      creditors_path
    else
      project_path
    end
  end
end
