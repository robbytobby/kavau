module PdfsHelper
  def options_for_letters(creditor)
    (possible_standard_letters(creditor) + possible_balance_letters(creditor)).
      select{ |letter| policy(letter).create? }.
      map{ |letter| [letter.title, letter.id] }
  end

  def possible_standard_letters(creditor)
    StandardLetter.all.order(subject: :asc).select{ |letter| letter.pdfs.where(creditor_id: creditor.id).empty? }
  end

  def possible_balance_letters(creditor)
    return [] if creditor.payments.none?
    BalanceLetter.where(['year >= ?', year_of_first_payment(creditor)]).
      order(year: :asc).all.
      select{ |letter| letter.pdfs.where(creditor_id: creditor.id).empty? }
  end

  def year_of_first_payment(creditor)
    creditor.payments.order('date asc').first.date.year
  end
end

