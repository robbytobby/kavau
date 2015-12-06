class BalanceLetter < Letter
  validates :year, presence: true

  def to_pdf(creditor)
    YearlyBalancePdf.new(creditor, self).render
  end

  def create_pdfs
    Address.creditors.all.each do |creditor|
      next if creditor.balances.where(date: Date.new(year).end_of_year).empty?
      creditor.pdfs.create!(letter: self)
    end
    touch(:pdfs_created_at)
  end

  def title
    self[:subject] || I18n.t('pdf.title.balance_letter', text: year)
  end
end
