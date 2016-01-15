class PaymentLetterPolicy < LetterPolicy
  def create?
    return false unless user.admin? || user.accountant?
    !PaymentLetter.any?    
  end

  def create_pdfs?
    false
  end
  
  def get_pdfs?
    false
  end
end

