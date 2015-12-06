module PdfsHelper
  def options_for_letters(creditor)
    (possible_standard_letters(creditor) + possible_balance_letters(creditor)).map{ |letter| [letter.title, letter.id] }
  end

  def possible_standard_letters(creditor)
    StandardLetter.all.select{ |letter| letter.pdfs.where(creditor_id: creditor.id).empty? }
  end

  def possible_balance_letters(creditor)
    BalanceLetter.where(['year >= ?', year_of_first_payment(creditor)]).all.select{ |letter| letter.pdfs.where(creditor_id: creditor.id).empty? }
  end

  def year_of_first_payment(creditor)
    creditor.payments.order('date asc').first.date.year
  end
end

