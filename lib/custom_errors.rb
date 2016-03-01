class CustomError < StandardError
  include Rails.application.routes.url_helpers

  def redirection
    :back
  end
end

class MissingInformationError < CustomError
  def initialize(object)
    @address = object 
  end

  def address
    @address
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

