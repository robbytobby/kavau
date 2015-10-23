class BicValidator < ActiveModel::Validator
  def validate(record)
    return if record.bic.blank?
    unless record.bic.match(/([a-zA-Z]{4}[a-zA-Z]{2}[a-zA-Z0-9]{2}([a-zA-Z0-9]{3})?)/)
      record.errors.add :bic, record.errors.generate_message(:bic, :invalid)
    end
  end
end
