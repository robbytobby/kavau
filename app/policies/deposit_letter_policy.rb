class DepositLetterPolicy < PaymentLetterPolicy
  def create?
    return false unless user.admin? || user.accountant?
    !DepositLetter.any?    
  end
end

