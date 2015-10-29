require 'iban-tools'

class IbanValidator < ActiveModel::Validator
  def validate(record)
    return if IBANTools::IBAN.valid?(record.iban)
    record.errors.add :iban, record.errors.generate_message(:iban, :invalid)
  end
end
