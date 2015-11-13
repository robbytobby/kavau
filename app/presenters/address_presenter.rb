class AddressPresenter < BasePresenter
  def full_name(format = :formal)
    if format == :formal
      [formal_name, first_name].compact.join(', ')
    else
      [first_name, name].compact.join(' ')
    end
  end

  def detail_line
    [address, mail_to, phone_numbers(separator: ' | ')].compact.join(' | ').html_safe
  end

  def notes_paragraph
    return if notes.blank?
    h.content_tag(:p,
      h.content_tag(:span,
        Address.human_attribute_name(:notes) + ': ', class: 'text-info'
      ) + notes
    )
  end

  def formal_name
    [title, name].compact.join(' ')
  end

  def address
    [street_number, city_line, country_name].compact.join(', ')
  end

  def city_line
    [zip, city].join(' ')
  end

  def country_name
    return nil unless country_code
    country = ISO3166::Country[country_code]
    country.translations[I18n.locale.to_s] || country.name
  end

  def phone_numbers(separator: ' | ')
    return unless phone
    (phone || '').gsub("\r\n", separator).html_safe
  end

  def confirmation_label
    full_name(:informal)
  end
end
