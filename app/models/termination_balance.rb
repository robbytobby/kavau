class TerminationBalance < AutoBalance
  after_destroy ->{ CreditAgreementTerminator.new(credit_agreement).reopen }
end
