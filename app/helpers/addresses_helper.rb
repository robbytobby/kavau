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

  def popover_notes(address)
    return if address.notes.blank?
    content_tag(:span, '', 
                class: 'glyphicon glyphicon-info-sign text-info', 
                data: {toggle: 'popover', content: address.notes}, title: Address.human_attribute_name(:notes))
  end
end
