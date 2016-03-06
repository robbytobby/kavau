class CustomError < StandardError
  include Rails.application.routes.url_helpers

  def redirection
    :back
  end

  def flash_type
    :alert
  end
end

class NoAccountError < CustomError
  def message
    I18n.t :no_accounts, scope: :exceptions
  end
end

class NoCreditorError < CustomError
  def message
    I18n.t :no_creditor, scope: :exceptions
  end

  def flash_type
    :warning
  end
end

class ConfigurationError < CustomError
  def message
    I18n.t :settings_invalid, scope: :exceptions
  end

  def flash_type
    :warning
  end

  def redirection
    settings_path
  end
end

class MissingInformationError < CustomError
  def initialize(object)
    @address = object 
  end

  def message
    nil
  end

  def redirection
    @address
  end
end

class MissingLetterTemplateError < CustomError
  def initialize(klass, year = nil)
    @klass = klass
    @year = year
  end

  def message
    I18n.t(@klass.model_name.singular, scope: [:exceptions, :missing_template_error], year: @year)
  end

  def redirection
    letters_path
  end
end


class MissingRegisteredSocietyError < CustomError
  def message
    I18n.t('exceptions.registered_society_missing')
  end

  def flash_type
    :warning
  end

  def redirection
    new_project_address_path
  end
end

class MissingTemplateError < CustomError
  def initialize(options)
    super
    @group = options[:group]
    @key = options[:key]
  end

  def message
    I18n.t(@key, scope: ['exceptions', 'file_not_found', @group] )
  end
end

