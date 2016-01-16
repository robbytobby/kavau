class PaymentLetterPolicy < LetterPolicy
  def create?
    return false unless user.admin? || user.accountant?
  end

  def create_pdfs?
    false
  end
  
  def get_pdfs?
    false
  end
end

