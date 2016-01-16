class DisburseLetterPolicy < PaymentLetterPolicy
  def create?
    return false unless user.admin? || user.accountant?
    !DisburseLetter.any?    
  end
end

