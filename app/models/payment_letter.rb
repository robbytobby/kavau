class PaymentLetter < Letter
  def to_pdf(payment)
    PaymentPdf.new(payment).render
  end

  def title
    subject || PaymentLetter.model_name.human
  end
end

