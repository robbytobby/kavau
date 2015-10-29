module CreditAgreementsHelper
  def edit_credit_agreement_path(credit_agreement)
    send(
      "edit_#{credit_agreement.creditor.type.underscore}_credit_agreement_path",
      credit_agreement.creditor, credit_agreement
    )
  end
end
