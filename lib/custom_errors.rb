class MissingInformationError < StandardError
  def initialize(object)
    @address = object 
  end

  def address
    @address
  end
end

class MissingLetterTemplateError < StandardError
  attr_reader :klass, :year
  def initialize(klass, year = nil)
    @klass = klass
    @year = year
  end
end


class MissingRegisteredSocietyError < StandardError

end

class MissingTemplateError < StandardError
  attr_reader :group, :key
  def initialize(options)
    super
    @group = options[:group]
    @key = options[:key]
  end
end
