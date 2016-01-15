class PdfStyles
  include BuildingBlock
  attr_reader :line_width

  def initialize(doc)
    @document = doc
    @logo_size = 5.35.cm
    @line_width = 0.1
    doc.line_width = @line_width
    doc.default_leading 3
  end

  def document
    @document
  end

  def footer_line(number)
    footer_options.merge footer_line_position(number)
  end

  def recipient
    { at: [0, 20.5.cm], height: 3.cm, width: 8.cm, overflow: :shrink_to_fit}
  end

  def over_address_line
    [[0, 21.5.cm], {width: 8.cm}]
  end

  def date
    { 
      at: [bounds.width - date_box_width, 15.cm], 
      width: date_box_width,
      align: :right,
      inline_format: true
    }
  end

  def footer_font_size
    8.5
  end

  def sender_font_size
    8
  end

  def contact_information_font_size
    10
  end

  def logo
    { position: :right, fit: [@logo_size, @logo_size] }
  end

  def logo_box
    [ [bounds.width - @logo_size + 0.8.cm, 25.0.cm], { :width => @logo_size} ]
  end

  private
  def footer_options
    { width: bounds.width + 0.8.cm, height: footer_line_height, inline_format: true, 
      overflow: :shrink_to_fit, align: :center  }
  end

  def footer_line_height
    14.pt
  end

  def footer_line_position(number)
    { at: [0, -1.cm - number * footer_line_height] }
  end

  def date_box_width
    4.cm
  end
end
