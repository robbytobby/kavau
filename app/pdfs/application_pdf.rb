require "prawn/measurement_extensions"
Prawn::Font::AFM.hide_m17n_warning = true

class ApplicationPdf < Prawn::Document
  include ActionView::Helpers::NumberHelper
  include I18nKeyHelper
  attr_reader :style, :recipient, :sender, :date

  def initialize(sender, recipient)
    super page_definition
    @date = Date.today
    @sender = PdfSender.new(sender, self)
    @recipient = PdfRecipient.new(recipient, self)
    @style = PdfStyles.new(self)
    @logo = PdfLogo.new(self)
    @first_page_template = get_first_page_template
    @following_page_template = get_following_page_template 
    set_custom_font
    make
  end

  def rendered
    return self.render unless @first_page_template
    pdf_with_template
  end

  def make
    recipient.address
    date_box
    layout unless @first_page_template
    move_cursor_to 15.cm
    stroke_color "7c7b7f"
    content
  end

  private
  def layout
    @sender.over_address_line
    @logo.draw
    repeat :all do
      stroke{ horizontal_line(-2.cm, -1.4.cm, at: 6.2.cm) }
      stroke{ horizontal_line(-2.cm, -1.4.cm, at: 16.4.cm) }
      @sender.footer
    end
  end

  def pdf_with_template
    pdf = CombinePDF.parse(self.render)
    pdf.pages(nil).each_with_index do |page, index| 
      page >> (index == 0 ? @first_page_template : @following_page_template)
    end
    pdf.to_pdf
  end

  def get_following_page_template
    return @first_page_template unless following_page_template_path
    CombinePDF.load(following_page_template_path).pages[0]
  end

  def following_page_template_path
    Letter.config[:templates][:following_page_template]
  end

  def get_first_page_template
    return nil unless first_page_template_path
    CombinePDF.load(first_page_template_path).pages[0]
  end

  def first_page_template_path
    Letter.config[:templates][:first_page_template]
  end

  def content
  end

  def page_definition
    { 
      page_size: 'A4', 
      page_layout: :portrait,
      top_margin: Letter.config[:layout][:top_margin].cm,
      bottom_margin: Letter.config[:layout][:bottom_margin].cm,
      left_margin: Letter.config[:layout][:left_margin].cm,
      right_margin: Letter.config[:layout][:right_margin].cm
    }.merge(background_definition)
  end 

  def background_definition
    {background: Letter.config[:templates][:watermark]}
  end

  def set_custom_font
    font_families.update(
      Letter.config[:custom_font][:font_name] => {
        #TODO set and upload
        normal: Letter.config[:custom_font][:normal],
        italic: Letter.config[:custom_font][:italic],
        bold: Letter.config[:custom_font][:bold],
        bold_italic: Letter.config[:custom_font][:bold_italic]
      })
  end
end

