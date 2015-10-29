class BicValidator < ActiveModel::Validator
  def validate(record)
    return if record.bic.blank? || record.bic.match(bic_regex)
    record.errors.add :bic, record.errors.generate_message(:bic, :invalid)
  end

  def bic_regex
    /([a-zA-Z]{4}[a-zA-Z]{2}[a-zA-Z0-9]{2}([a-zA-Z0-9]{3})?)/
  end
end
