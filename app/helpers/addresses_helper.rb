module AddressesHelper
  # not used?
  # def new_model_path
  #   send("new_#{@type.underscore}_path")
  # end

  def cancel_path(address)
    if address.creditor?
      creditors_path
    else
      project_path
    end
  end

  def legal_form_options
    I18n.t('legal_forms').stringify_keys.to_a.map(&:reverse)
  end

  def icon_popover(icon, content, title = '', placement = 'top')
    return if content.blank?
    content_tag(:span,
                '',
                class: "glyphicon glyphicon-#{icon} text-info",
                data: {
                  toggle: 'popover',
                  content: content,
                  placement: placement
                },
                title: title)
  end
end
