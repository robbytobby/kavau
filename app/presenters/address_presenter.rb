class AddressPresenter < BasePresenter
  def full_name(format = :formal)
    if format == :formal
      [[title, name].join(' '), first_name].join(', ')
    else
      [first_name, name].join(' ')
    end
  end

  def address
    [street_number, [zip, city].join(' '), country_name].join(', ')
  end

  def country_name
    country = ISO3166::Country[country_code]
    country.translations[I18n.locale.to_s] || country.name
  end

  def phone_numbers
    (phone || '').gsub("\r\n", '</br>').html_safe
  end

end
