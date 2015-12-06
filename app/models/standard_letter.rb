class StandardLetter < Letter
  def to_pdf(creditor)
    LetterPdf.new(creditor, self).render
  end

  def create_pdfs
    Address.creditors.all.each do |creditor|
      creditor.pdfs.create!(letter: self)
    end
    touch(:pdfs_created_at)
  end
  
  def title
    subject
  end
end
