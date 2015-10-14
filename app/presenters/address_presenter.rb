class AddressPresenter < BasePresenter
  def full_name(format = :formal)
    if format == :formal
      [[title, name].join(' '), first_name].compact.join(', ')
    else
      [first_name, name].compact.join(' ')
    end
  end

  def address
    [street_number, [zip, city].join(' '), country_name].compact.join(', ')
  end

  def country_name
    return nil unless country_code
    country = ISO3166::Country[country_code]
    country.translations[I18n.locale.to_s] || country.name
  end

  def phone_numbers(br: true)
    if br
      (phone || '').gsub("\r\n", '</br>').html_safe
    else
      (phone || '').gsub("\r\n", ' | ')
    end
  end
end
