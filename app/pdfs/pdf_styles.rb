class PdfStyles
  include BuildingBlock
  attr_reader :line_width

  def initialize(doc)
    @document = doc
    @logo_size = 6.cm
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
    { at: [0, 21.5.cm], height: 3.cm, width: 8.cm, overflow: :shrink_to_fit }
  end

  def over_address_line
    [[0, 22.8.cm], {width: 8.cm, overflow: :shrink_to_fit}]
  end

  def over_address_line_ruler
   [[0, 22.4.cm], [8.cm, 22.4.cm]]
  end

  def date
    { 
      at: [bounds.width - date_box_width, 18.cm], 
      width: date_box_width,
      align: :right,
      inline_format: true
    }
  end

  def footer_font_size
    9
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
    [ [bounds.width - @logo_size, 25.5.cm], { :width => @logo_size} ]
  end

  private
  def footer_options
    { width: bounds.width, height: footer_line_height, inline_format: true, overflow: :shrink_to_fit }
  end

  def footer_line_height
    (page.margins[:bottom] - 2.0.cm) / 3
  end

  def footer_line_position(number)
    { at: [0, 0 - number * footer_line_height - 0.8.cm ] }
  end

  def date_box_width
    4.cm
  end
end
