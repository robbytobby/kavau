class UserPresenter < BasePresenter
  def full_name
    [first_name, name].compact.join(' ')
  end

  def phone_numbers(separator: ' | ')
    return unless phone
    (phone || '').gsub("\r\n", separator).html_safe
  end

  def human_role
    I18n.t("roles.#{role}")
  end

  def confirmation_label
    full_name
  end
end
