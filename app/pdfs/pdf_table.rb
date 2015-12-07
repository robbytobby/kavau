class PdfTable
  include BuildingBlock

  def initialize(doc, content, options)
    @document = doc
    @content = content
    @options = options
  end

  def document
    @document
  end

  def draw
    table @content, standard_options do |table|
      @table = table
      apply_options
    end
  end

  private
  def apply_options
    right_align
    bold
    thick_border
    top_border
  end

  def right_aligned_columns
    @options[:right_align]
  end

  def bold_rows
    @options[:bold_rows]
  end

  def thick_border_rows
    @options[:thick_border_rows]
  end

  def top_border_rows
    @options[:top_border_rows] || [-1]
  end

  def right_align
    @table.columns(right_aligned_columns).align = :right
  end

  def bold
    bold_rows.each do |r|
      @table.row(r).font_style = :bold
    end
  end

  def thick_border
    thick_border_rows.each do |r|
      @table.row(r).border_width = 5 * line_width
    end
  end

  def top_border
    top_border_rows.each do |r|
      @table.row(r).borders = [:top]
    end
  end

  def standard_options
    { 
      cell_style: cell_defaults,
      width: bounds.width
    }
  end

  def cell_defaults
    { 
      size: 10, 
      borders: [:bottom], 
      border_width: style.line_width,
      inline_format: true, 
      overflow: :shrink_to_fit
    }
  end
end

