class PdfPolicy < ApplicationPolicy

  def edit?
    return false if @record.termination_letter?
    return !next_years_letter_exists? if @record.balance_letter?
    super
  end

  def create?
    return true unless @record.try(:letter)
    return !next_years_letter_exists? if @record.balance_letter?
    super
  end

  def destroy?
    return false if @record.termination_letter?
    return !next_years_letter_exists? if @record.balance_letter?
    super
  end

  def permitted_params
    [:letter_id]
  end

  private
  def next_years_letter_exists?
    Pdf.joins(:letter).where(creditor_id: @record.creditor_id,
                             letters: {type: 'BalanceLetter', year: @record.letter.year + 1}
                            ).exists?
  end
end
