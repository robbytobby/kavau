def dont_validate_fund_for(object)
  if object.is_a?(Class)
    dont_validate_class(object)
  else
    dont_validate_instance(object)
  end
end

def dont_validate_class(klass)
  fund_validations.each{ |name| allow_any_instance_of(klass).to receive(name).and_return(true) }
end

def dont_validate_instance(object)
  fund_validations.each{ |name| allow(object).to receive(name).and_return(true) }
end

def fund_validations
  [:fund_exists?, :after_fund_issuing]
end
