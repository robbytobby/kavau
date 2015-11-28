class PdfLogo
  include Prawn::View
  delegate :style, to: :document

  def initialize(doc)
    @document = doc
  end

  def document
    @document
  end

  def draw
    return unless FileTest.exists?(logo_path)
    bounding_box(*style.logo_box) do
      image logo_path, style.logo
    end
  end

  private
  def logo_path
    "#{Rails.root}/app/assets/images/logo.png"
  end
end

