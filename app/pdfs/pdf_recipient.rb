class PdfRecipient
  include Prawn::View
  attr_reader :model, :presented
  delegate :style, to: :document
  delegate :full_name, :street_number, :city_line, :country_name, to: :presented

  def initialize(recipient, doc)
    @document = doc
    @model = recipient
    @presented = CreditorPresenter.new(@model, self)
  end

  def address
    text_box recipient_data, style.recipient
  end

  def recipient_data
    [full_name(:pdf), street_number, city_line, country_name].join("\n")
  end
end

