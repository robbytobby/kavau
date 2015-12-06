class BalanceLetterPolicy < LetterPolicy
  def get_pdfs?
    return false if @record.year.blank?
    super
  end

  def create_pdfs?
    return false if @record.year.blank?
    super
  end
end

