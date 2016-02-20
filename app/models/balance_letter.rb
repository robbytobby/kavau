class BalanceLetter < Letter
  validates :year, presence: true

  def to_pdf(creditor)
    YearlyBalancePdf.new(creditor, self).rendered
  end

  def create_pdfs
    Address.creditors.all.each do |creditor|
      next if creditor.balances.where(date: Date.new(year).end_of_year).empty?
      creditor.pdfs.create!(letter: self)
    end
    touch(:pdfs_created_at)
  end

  def title
    I18n.t('pdf.title.balance_letter', text: year)
  end

  def self.last_for(creditor_id)
    joins(:pdfs).where(pdfs: {creditor_id: creditor_id}).order(year: :desc).first
  end
end
