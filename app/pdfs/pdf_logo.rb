class PdfLogo
  include BuildingBlock

  def initialize(doc)
    @document = doc
  end

  def document
    @document
  end

  def draw
    return unless logo_path
    bounding_box(*style.logo_box) do
      image logo_path, style.logo
    end
  end

  private
  def logo_path
    Letter.config[:templates][:logo]
  end
end

